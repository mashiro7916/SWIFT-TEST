# ARKit 深度捕獲應用程式

這是一個使用 ARKit 在 iPad 上捕獲 RGB 圖像和 LiDAR 深度圖的 iOS 應用程式。

## 功能特點

- ✅ 使用 ARKit 捕獲實時 RGB 圖像
- ✅ 使用 LiDAR 感測器捕獲深度圖
- ✅ 自動儲存捕獲的圖像到設備文檔目錄
- ✅ 支援 iPad 全螢幕顯示
- ✅ 簡潔的用戶界面

## 系統要求

- iPad Pro (2020 或更新版本) 或 iPad Air (第 4 代或更新版本)
- iOS 14.0 或更高版本
- 需要支援 LiDAR 的設備

## 安裝說明

1. 使用 Xcode 打開 `ARKitDepthCapture.xcodeproj`
2. 選擇目標設備（必須是支援 LiDAR 的 iPad）
3. 連接您的 iPad 到 Mac
4. 在 Xcode 中點擊運行按鈕

## 使用方法

1. 啟動應用程式後，AR 會話會自動開始
2. 將 iPad 對準您想要捕獲的場景
3. 點擊「捕獲圖像」按鈕
4. 應用程式會同時儲存 RGB 圖像和深度圖
5. 圖像會儲存在設備的文檔目錄中

## 儲存位置

捕獲的圖像會儲存在應用程式的文檔目錄中：
- RGB 圖像：`RGB_[時間戳].png`
- 深度圖：`Depth_[時間戳].png`

您可以通過 Xcode 的設備管理器或文件應用程式訪問這些圖像。

## 技術細節

- **框架**: ARKit, SceneKit, AVFoundation
- **語言**: Swift 5.0
- **最低部署目標**: iOS 14.0
- **AR 配置**: ARWorldTrackingConfiguration with Scene Reconstruction

## 注意事項

- 此應用程式需要相機權限
- 僅在支援 LiDAR 的設備上運行
- 深度圖的質量取決於環境光照條件

## 授權

此專案僅供學習和開發使用。

