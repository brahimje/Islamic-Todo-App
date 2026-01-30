# Android Release Signing Setup Guide

## Step 1: Generate a Keystore

Run this command in your terminal:

```bash
keytool -genkey -v -keystore ~/islamic-todo-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias islamic-todo
```

You'll be asked to enter:
- Keystore password (keep this secure!)
- Key password (can be the same as keystore password)
- Your name/organization details

**IMPORTANT:** Store these passwords securely! You'll need them for every release.

## Step 2: Create key.properties File

1. Create a file named `key.properties` in the `android/` directory
2. Add the following content (replace with your actual values):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=islamic-todo
storeFile=/Users/YOUR_USERNAME/islamic-todo-release.jks
```

Replace:
- `YOUR_KEYSTORE_PASSWORD` with your keystore password
- `YOUR_KEY_PASSWORD` with your key password  
- `YOUR_USERNAME` with your macOS username

## Step 3: Secure the Keystore

1. Move keystore to a secure location:
```bash
mv ~/islamic-todo-release.jks ~/Documents/islamic-todo-release.jks
```

2. Update `storeFile` path in `key.properties`

3. **NEVER commit key.properties or .jks files to Git!** (Already in .gitignore)

## Step 4: Build Release APK

```bash
flutter build apk --release
```

Or build App Bundle (recommended for Play Store):
```bash
flutter build appbundle --release
```

## Backup Your Keystore

**CRITICAL:** Make secure backups of:
1. `islamic-todo-release.jks` file
2. Your keystore password
3. Your key password

If you lose these, you **cannot** update your app on Google Play Store!

Recommended backup locations:
- Encrypted cloud storage (Google Drive, iCloud with encryption)
- Password manager (1Password, LastPass, Bitwarden)
- External encrypted USB drive

## Troubleshooting

### Build fails with signing error:
- Check that `key.properties` exists in `android/` folder
- Verify all paths are correct in `key.properties`
- Ensure passwords are correct

### "storeFile not found":
- Use absolute path in `storeFile` property
- Check file actually exists at that location

### For first-time release without keystore:
The app will use debug signing temporarily. Create keystore before releasing to production!
