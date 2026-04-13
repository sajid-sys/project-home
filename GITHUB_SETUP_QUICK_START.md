# GitHub Deployment Quick Start - 5 Minutes

## Step 1: Initialize Git (2 minutes)

```bash
cd c:\Users\Shahriar Hossen\bari_project

git init
git add .
git commit -m "Initial commit: Project Home Sweet Home"
```

## Step 2: Create GitHub Repository (1 minute)

1. Go to https://github.com/new
2. Repository name: `bari_project` (or `Project-Home-Sweet-Home`)
3. Description: "Home Building Fund Management App"
4. Click **Create repository**

## Step 3: Push to GitHub (1 minute)

Copy the commands GitHub shows you:

```bash
# Example (replace with your GitHub username):
git remote add origin https://github.com/YOUR_USERNAME/bari_project.git
git branch -M main
git push -u origin main
```

## Step 4: Set Up GitHub Secrets (1 minute)

Go to: **Settings → Secrets and variables → Actions → New repository secret**

Add:
- `FIREBASE_PROJECT_ID` = `your_firebase_id`
- `FIREBASE_STORAGE_BUCKET` = `your_bucket_name`
- `PLAY_STORE_SERVICE_ACCOUNT` = (paste Google Play JSON file contents)

**Done! ✅ GitHub Actions will now auto-build on every push**

---

## Next: Deploy to Google Play Store

1. **Create Google Play Console account**: https://play.google.com/console ($20)
2. **Download service account JSON**: Play Console → Settings → API access
3. **Add to GitHub Secrets** as `PLAY_STORE_SERVICE_ACCOUNT`
4. **Tag a release**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
5. **Monitor deployment**: Go to Actions tab and watch the workflow run

---

## Check Status

- **Build status**: Go to **Actions** tab
- **Download builds**: Click completed workflow → Download artifacts
- **View releases**: Go to **Releases** page

---

## Common Commands

```bash
# Check current status
git status

# See commits
git log --oneline

# Create new branch
git checkout -b feature/my-feature

# Push changes
git add .
git commit -m "Describe changes"
git push origin feature/my-feature

# Create release
git tag v1.0.0
git push origin v1.0.0
```

## Troubleshooting

| Issue | Solution |
|---|---|
| "Permission denied" | Check GitHub SSH key setup |
| "fatal: could not create work tree" | Ensure folder permissions |
| Build failed in Actions | Check logs → usually missing secrets |
| APK not uploading | Verify `PLAY_STORE_SERVICE_ACCOUNT` secret |

---

**More details**: See `DEPLOYMENT_GUIDE.md`
