extends PopupPanel
## 在线更新弹窗：从 GitHub 静态托管拉取 update.json，展示更新内容与 QQ 群二维码。
## 二维码由 docs/qq_group.png 提供，替换仓库内图片即可“实时”更新，无需重新发布游戏。

# 当前游戏本地版本，发布新版本时同步修改。
const LOCAL_VERSION_CODE := 30
const LOCAL_VERSION_TEXT := "0.3.0"

# GitHub Pages 地址（仓库开启 Pages 后生效）。
const UPDATE_URL_PRIMARY := "https://mU1yZ5fS.github.io/fE9dO9tI/update.json"
# raw 地址作为备用，公开仓库不需要先开启 Pages 也能访问。
const UPDATE_URL_FALLBACK := "https://raw.githubusercontent.com/mU1yZ5fS/fE9dO9tI/main/docs/update.json"

@onready var _title: Label = $布局/标题
@onready var _status: Label = $布局/状态
@onready var _announcement: Label = $布局/公告
@onready var _changelog: RichTextLabel = $布局/日志滚动/更新日志
@onready var _qr: TextureRect = $布局/二维码区/二维码
@onready var _qr_status: Label = $布局/二维码区/二维码说明/二维码状态
@onready var _qq_name: Label = $布局/二维码区/二维码说明/群名称
@onready var _download_btn: Button = $布局/按钮行/下载
@onready var _join_btn: Button = $布局/按钮行/加入QQ群
@onready var _close_btn: Button = $布局/按钮行/关闭

var _download_url := ""
var _join_url := ""
var _qr_url := ""
var _used_fallback := false


func _ready() -> void:
	_download_btn.pressed.connect(_open_download)
	_join_btn.pressed.connect(_open_qq)
	_close_btn.pressed.connect(close_popup)


func open_update_popup() -> void:
	_show_loading()
	popup_centered()
	_fetch_update()


func close_popup() -> void:
	hide()


func _show_loading() -> void:
	_used_fallback = false
	_title.text = "更新公告"
	_status.text = "正在检查更新…"
	_announcement.text = ""
	_changelog.text = "正在连接更新服务器…"
	_download_url = ""
	_join_url = ""
	_qr_url = ""
	_download_btn.disabled = true
	_join_btn.disabled = true
	_qr.texture = null
	_qr_status.text = "二维码加载中…"
	_qq_name.text = "QQ交流群"


func _fetch_update() -> void:
	_used_fallback = false
	_request_json(UPDATE_URL_PRIMARY)


func _request_json(url: String) -> void:
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_json_completed.bind(http, url))
	var err := http.request(url)
	if err != OK:
		http.queue_free()
		_on_json_request_failed(url)


func _on_json_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
	http: HTTPRequest,
	url: String
) -> void:
	http.queue_free()
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var parsed = JSON.parse_string(body.get_string_from_utf8())
		if parsed is Dictionary:
			_apply_update(parsed)
			return
	_on_json_request_failed(url)


func _on_json_request_failed(url: String) -> void:
	if url == UPDATE_URL_PRIMARY and not _used_fallback:
		_used_fallback = true
		_request_json(UPDATE_URL_FALLBACK)
		return
	_status.text = "无法连接更新服务器"
	_changelog.text = "请检查网络后重试，或稍后再试。"
	_download_btn.disabled = true
	_join_btn.disabled = true


func _apply_update(data: Dictionary) -> void:
	var remote_version := str(data.get("version", "未知"))
	var remote_code := int(data.get("version_code", 0))
	var display_title := str(data.get("title", "游戏更新"))

	_title.text = display_title
	_download_url = str(data.get("download_url", ""))
	_download_btn.disabled = _download_url.is_empty()

	if remote_code > LOCAL_VERSION_CODE:
		_status.text = "发现新版本：v%s（当前 v%s）" % [remote_version, LOCAL_VERSION_TEXT]
	elif remote_code == LOCAL_VERSION_CODE:
		_status.text = "当前已是最新版本：v%s" % remote_version
	else:
		_status.text = "当前版本：v%s" % remote_version

	var announcement := str(data.get("announcement", ""))
	_announcement.text = announcement

	var lines := ""
	for item in data.get("changelog", []):
		lines += "• " + str(item) + "\n"
	if lines.is_empty():
		lines = "暂无更新内容。"
	_changelog.text = lines

	var qq_variant = data.get("qq_group", {})
	var qq: Dictionary = qq_variant if qq_variant is Dictionary else {}
	var qq_name := str(qq.get("name", "QQ交流群"))
	_qq_name.text = qq_name
	_qr_url = str(qq.get("qr_url", ""))
	_join_url = str(qq.get("join_url", ""))

	if _join_url.is_empty():
		_join_btn.text = "查看二维码"
		_join_btn.disabled = _qr_url.is_empty()
	else:
		_join_btn.text = "加入%s" % qq_name
		_join_btn.disabled = false

	if _qr_url.is_empty():
		_qr.texture = null
		_qr_status.text = "暂未提供二维码图片"
	else:
		_load_qr(_qr_url)


func _load_qr(url: String) -> void:
	_qr_status.text = "二维码加载中…"
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_qr_completed.bind(http))
	var err := http.request(url)
	if err != OK:
		http.queue_free()
		_qr_status.text = "二维码加载失败"


func _on_qr_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray,
	http: HTTPRequest
) -> void:
	http.queue_free()
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var img := Image.new()
		var err := img.load_png_from_buffer(body)
		if err == OK:
			_qr.texture = ImageTexture.create_from_image(img)
			_qr_status.text = ""
			return
	_qr.texture = null
	_qr_status.text = "二维码图片加载失败，请稍后重试"


func _open_download() -> void:
	if not _download_url.is_empty():
		OS.shell_open(_download_url)


func _open_qq() -> void:
	if not _join_url.is_empty():
		OS.shell_open(_join_url)
	elif not _qr_url.is_empty():
		OS.shell_open(_qr_url)
