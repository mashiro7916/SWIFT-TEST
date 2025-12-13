# Xcode Setup Guide for iPad Deployment

## Prerequisites

1. **Mac with Xcode installed** (Xcode 14.0 or later recommended)
2. **iPad with LiDAR support**:
   - iPad Pro 11-inch (2nd generation or later)
   - iPad Pro 12.9-inch (4th generation or later)
   - iPad Air (4th generation or later)
3. **USB-C or Lightning cable** to connect iPad to Mac
4. **Apple Developer Account** (free account is sufficient for development)

## Step-by-Step Setup Instructions

### 1. Open the Project in Xcode

1. Open **Xcode** on your Mac
2. Go to **File → Open** (or press `Cmd + O`)
3. Navigate to the project folder: `ARKitDepthCapture`
4. Select `ARKitDepthCapture.xcodeproj` and click **Open**

### 2. Configure Project Settings

1. In the **Project Navigator** (left sidebar), click on the **blue project icon** at the top (ARKitDepthCapture)
2. Select the **ARKitDepthCapture** target under **TARGETS**
3. Go to the **General** tab

#### Configure Bundle Identifier:
- Find **Bundle Identifier**
- Change from `com.example.ARKitDepthCapture` to something unique like:
  - `com.yourname.ARKitDepthCapture` (replace `yourname` with your name/company)

#### Configure Deployment Info:
- **iOS Deployment Target**: Should be set to **14.0** or higher
- **Devices**: Select **iPad** (or Universal if you want both iPhone and iPad)
- **Supported Device Families**: Make sure **iPad** is checked

### 3. Configure Signing & Capabilities

1. Still in the **General** tab, scroll down to **Signing & Capabilities**
2. Check **Automatically manage signing**
3. Select your **Team** from the dropdown (you may need to add your Apple ID)
   - If you don't have a team, click **Add Account...** and sign in with your Apple ID
4. Xcode will automatically generate a provisioning profile

### 4. Connect Your iPad

1. Connect your iPad to your Mac using a USB-C or Lightning cable
2. On your iPad, if prompted, tap **Trust This Computer** and enter your passcode
3. In Xcode, you should see your iPad appear in the device selector (top toolbar)

### 5. Select Your iPad as the Target Device

1. In the top toolbar, click on the **device selector** (next to the Run/Stop buttons)
2. You should see your connected iPad listed
3. Select your iPad from the list
   - If your iPad doesn't appear, make sure:
     - It's unlocked
     - You've trusted the computer
     - It's connected via USB (not just Wi-Fi)

### 6. Build and Run

1. Click the **Play button** (▶️) in the top-left corner, or press `Cmd + R`
2. Xcode will:
   - Build the project
   - Install the app on your iPad
   - Launch the app automatically

### 7. Trust the Developer Certificate (First Time Only)

If this is the first time installing an app from this developer on your iPad:

1. On your iPad, go to **Settings → General → VPN & Device Management**
2. Find your developer certificate under **Developer App**
3. Tap it and select **Trust**
4. Return to the app and it should launch

## Troubleshooting

### Issue: "No devices found"
- **Solution**: 
  - Make sure iPad is unlocked
  - Check USB connection
  - Try a different USB cable
  - Restart Xcode

### Issue: "Code signing error"
- **Solution**:
  - Go to **Signing & Capabilities** tab
  - Make sure **Automatically manage signing** is checked
  - Select a valid Team
  - Change Bundle Identifier to something unique

### Issue: "Device not supported"
- **Solution**:
  - Make sure your iPad has LiDAR (iPad Pro 2020+ or iPad Air 4+)
  - Check iOS version (needs iOS 14.0+)

### Issue: "ARKit session failed"
- **Solution**:
  - Grant camera permissions when prompted
  - Make sure you're in a well-lit environment
  - Restart the app

### Issue: App crashes on launch
- **Solution**:
  - Check Xcode console for error messages
  - Make sure all required frameworks are linked
  - Verify Info.plist has camera permission description

## Accessing Captured Images

After capturing images, you can access them:

1. **Via Xcode**:
   - Go to **Window → Devices and Simulators**
   - Select your iPad
   - Click on your app
   - Click **Download Container...**
   - Right-click the downloaded container → **Show Package Contents**
   - Navigate to `AppData/Documents/` to find saved images

2. **Via Files App** (if you add file sharing):
   - Add `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace` to Info.plist
   - Images will appear in Files app under your app's folder

## Additional Notes

- The app requires **camera permissions** - grant when prompted
- Make sure your iPad has **sufficient storage** for captured images
- **LiDAR works best** in well-lit environments
- Each capture saves two files: `RGB_[timestamp].png` and `Depth_[timestamp].png`

## Build Configuration

- **Debug**: For development and testing
- **Release**: For final builds (optimized)

To switch: Go to **Product → Scheme → Edit Scheme** → Select **Run** → Change **Build Configuration**

