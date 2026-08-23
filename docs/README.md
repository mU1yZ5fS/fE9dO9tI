# 更新中心说明

本目录用于 GitHub Pages 静态托管：

- `index.html`：玩家可访问的更新公告页
- `update.json`：游戏端读取的更新数据
- `qq_group.png`：QQ群二维码图片

## 如何发布新版本提示

1. 修改 `update.json`：
   - `version`：展示用的版本号
   - `version_code`：整数版本号，必须比旧版大，游戏用它判断“有没有新版本”
   - `changelog`：更新内容列表
   - `download_url`：下载地址（建议指向 GitHub Releases）
2. 提交并推送到 `main` 分支。
3. GitHub Pages / raw 地址会自动更新，游戏下次检查即可看到。

## 如何更新 QQ 群二维码

直接覆盖 `docs/qq_group.png`，推送到 `main` 即可。
游戏始终从远程加载这张图片，所以不需要重新发布游戏本体。

如果还希望提供“点击加入QQ群”，可在 `update.json` 的 `qq_group.join_url` 填入群邀请链接。

## 地址

- GitHub Pages 更新页：`https://mU1yZ5fS.github.io/fE9dO9tI/`
- 更新数据（Pages）：`https://mU1yZ5fS.github.io/fE9dO9tI/update.json`
- 更新数据（raw 兼容）：`https://raw.githubusercontent.com/mU1yZ5fS/fE9dO9tI/main/docs/update.json`
- QQ 群二维码（raw）：`https://raw.githubusercontent.com/mU1yZ5fS/fE9dO9tI/main/docs/qq_group.png`

## 开启 GitHub Pages

仓库 Settings → Pages → Source 选 `GitHub Actions`，本仓库已附带
`.github/workflows/pages.yml`；也可以选 `Deploy from a branch`，
分支 `main`、目录 `/docs`。
