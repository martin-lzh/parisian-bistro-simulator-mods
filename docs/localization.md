# Languages / 多语言适配

[English](#english) · [中文](#中文)

## English

Mods with original interface text select their language from the running game. The supported set matches the 14 cultures configured for the local game baseline; Portuguese and Brazilian Portuguese are separate choices. Fresh to Serve and Scan to Order add no interface text and continue using the game's localized displays. No language pack or Mod language setting is required.

| Culture | Language | 语言 |
| --- | --- | --- |
| `en` | English | 英语 |
| `fr` | French | 法语 |
| `zh-Hans` | Simplified Chinese | 简体中文 |
| `it` | Italian | 意大利语 |
| `es` | Spanish | 西班牙语 |
| `de` | German | 德语 |
| `ru` | Russian | 俄语 |
| `ja` | Japanese | 日语 |
| `ko` | Korean | 韩语 |
| `zh-Hant` | Traditional Chinese | 繁体中文 |
| `tr` | Turkish | 土耳其语 |
| `pl` | Polish | 波兰语 |
| `pt` | Portuguese | 葡萄牙语 |
| `pt-BR` | Brazilian Portuguese | 巴西葡萄牙语 |

### What stays native

- **Bartender's Note:** drink names come from the game's current translation lookup, and the HUD uses the restaurant name bar's font and appearance. Different drinks with the same translated name remain separate types.
- **Auto Checkout:** payment prompts, notifications, item names and transaction behavior remain the game's own. The Mod adds no replacement payment interface.
- **Fresh to Serve:** dish/drink names and order displays remain native. It adds no player interface or replacement text catalog.
- **First to Serve:** the hold-to-collect hint has original translations. Its interaction key, remapping, controller icon, font and layout use the native interaction-key widget.
- **Smart Delivery:** delivery names come from the existing game buttons; only the new field label has Mod-owned translations.
- **Auto Menu:** dish names, forecast and compatibility stay native; only the composition button and tooltip have original translations.
- **Scan to Order:** customer orders, dish/drink names and order displays remain native. It adds no player interface or replacement text catalog.

Original translations cover Bartender's Note's hidden-type count and last-resort missing-name fallback, Auto Checkout's readable log explanations, First to Serve's hold hint, Smart Delivery's field label, and Auto Menu's button and tooltip. Game catalogs, assets and translated drink dictionaries are not bundled.

### Fallbacks and diagnostics

An unsupported or unavailable language falls back to English for Mod-owned wording. A missing native drink name first uses the game's translated “Drinks” category and `#ID`; if that lookup also fails, it uses the Mod's translated generic drink label and ID. The actual count is retained. Language changes are picked up during normal refreshes; font coverage and layout across all languages still require game testing.

First to Serve and Smart Delivery protect the runtime language lookup, including object validity checks and conversion to a Lua string. A temporary failure displays their English hint or field label without stopping item pickup or the delivery selector. They retry during subsequent refreshes and restore the selected language once reading succeeds. Smart Delivery's delivery choices still use the game's native labels.

Auto Checkout keeps `[AutoCheckout]`, event names such as `REQUEST` and `ERROR`, field names, phase identifiers and exception details stable for diagnosis. Its translated explanations help readers interpret the event without changing those identifiers. Logs can therefore contain native names, translated explanations and English technical details together.

Bartender's Note localizes its HUD; its technical loader/error diagnostics stay English. Auto Checkout translates six categories of explanation: host activation, AI restoration failure, restoration scheduling failure, stop after an error, unavailable notification listener, and exhausted retries. Messages before its first safe game-thread language read remain English, including early startup/listener-registration errors.

Fresh to Serve, First to Serve, Smart Delivery, Auto Menu and Scan to Order keep technical startup, event and error diagnostics in English. These logs are for troubleshooting; they are separate from the translated player interface and native game wording.

### Validation

The development guides describe offline checks and the in-game test checklist. Test all 14 translation entries, supported locale aliases, English fallback and recovery after language-read failures where a Mod owns text. First to Serve and Smart Delivery include offline tests for failure and recovery in their UI language lookup. Translation coverage is not proof of glyph rendering, language switching or game/loader compatibility. The [validation record](../releases/validation.md#english) includes the 2026-09-26 report that all Mods completed in-game testing; language-by-language results were not supplied separately, and later fixes require further testing. Keep any extracted language references and research notes in ignored `work/`.

## 中文

包含原创界面文案的 Mod 根据正在运行的游戏选择语言，覆盖本机游戏基线配置的 14 种语言，完整列表及语言代码见上表。Fresh to Serve 与 Scan to Order 不新增界面文案，继续使用游戏原生的本地化显示。葡萄牙语与巴西葡萄牙语独立处理，无需额外语言包或 Mod 语言设置。

### 优先沿用原生值

- **Bartender's Note（调饮手记）：**饮料名称从游戏当前翻译接口读取，HUD 沿用餐厅名称条的字体和外观。不同饮料即使译名相同，仍分别统计种类。
- **Auto Checkout（收银管家）：**保留游戏原有付款提示、通知、物品名称与交易行为，不替换付款界面。
- **Fresh to Serve（焕鲜上桌）：**菜品、饮料名称与订单显示沿用原生内容，不新增玩家界面或替换翻译词表。
- **First to Serve（出餐有序）：**长按取餐提示使用原创翻译；交互按键、改键、手柄图标、字体和布局使用原生交互按键控件。
- **Smart Delivery（配送随心）：**配送名称读取游戏现有按钮，仅新增字段标题使用 Mod 自有翻译。
- **Auto Menu（菜单巧配）：**菜名、预测和匹配显示沿用原生内容；仅自动组合按钮和提示使用原创翻译。
- **Scan to Order（扫码点餐）：**顾客订单、菜品／饮料名称及订单显示沿用原生内容，不新增玩家界面或替换翻译词表。

原创翻译覆盖 Bartender's Note 的隐藏种类计数及最终名称后备标签、Auto Checkout 的日志说明、First to Serve 的长按提示、Smart Delivery 的字段标题，以及 Auto Menu 的按钮和提示。不打包游戏翻译目录、资产或饮料译名字典。

### 后备显示与诊断

语言不可读或不在支持范围时，Mod 自有文案回退英语。原生饮料名缺失时，先使用游戏原生的“饮料”分类翻译加 `#编号`；该查询也失败时，再使用 Mod 自有的本地化通用饮料标签加编号。实际数量保持不变。正常刷新会读取语言变化；各语言字形与布局仍需实机检查。

First to Serve 和 Smart Delivery 对运行时语言查询进行异常保护，包含对象有效性检查及 Lua 字符串转换。临时失败时，长按提示或字段标题回退英语，不会因此停止取餐或配送选择器；后续刷新继续尝试，读取成功后恢复游戏所选语言。Smart Delivery 的配送选项仍使用游戏原生名称。

Auto Checkout 保留 `[AutoCheckout]`、`REQUEST` / `ERROR` 等事件名、字段名、阶段标识和异常详情，方便持续诊断。本地化说明用于解释事件，不改写这些标识，因此日志可能同时包含原生名称、本地化说明和英文技术信息。

Bartender's Note 本地化的是 HUD，加载器及异常等技术日志仍使用英文。Auto Checkout 翻译六类说明：房主启用、AI 恢复失败、恢复调度失败、异常后停止、提醒监听不可用及重试耗尽。首次安全的游戏线程语言读取之前，启动和早期监听注册错误等信息仍使用英语。

Fresh to Serve、First to Serve、Smart Delivery、Auto Menu 和 Scan to Order 的启动、事件及错误等技术日志保留英文。这些日志用于排查问题，与已翻译的玩家界面及原生游戏文案分别处理。

### 验证范围

各 Mod 开发说明列出离线检查与实机回归步骤。存在 Mod 自有文案时，应测试 14 种翻译、支持的语言代码别名、英语回退以及语言读取失败后的恢复。First to Serve 和 Smart Delivery 已包含界面语言读取失败及恢复的离线测试。翻译覆盖不代表已验证字形、语言切换或游戏和加载器兼容性。[验收记录](../releases/validation.md#中文)已收录 2026-09-26 全部 Mod 实机测试完成的反馈，用户未单独提供逐语言结果，后续修复仍须继续测试。提取的语言参考及研究笔记始终保留在被忽略的 `work/`。
