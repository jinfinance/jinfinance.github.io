#!/bin/bash

# so I have 2 folders, linked to 'main' and 'gh-pages' branches
# folders are: my-website and gh-pages-deploy
# you will also have hugo and PaperMod installed as well (ask chatGPT)

set -e  # Exit on error

echo "Building Hugo site..."
hugo --minify

echo "Switching to gh-pages branch..."
cd ../gh-pages-deploy

echo "Removing old files..."
# Remove all files except .git directory
git rm -rf . >/dev/null 2>&1 || true
# Just in case, also remove any leftover files
find . -mindepth 1 ! -regex '^./\.git\(/.*\)?' -exec rm -rf {} +

echo "Copying new public/ content..."
cp -r ../my-website/public/* .

echo "Adding all changes..."
git add .

echo "Committing changes..."
git commit -m "Deploy updated site from hugo build"

echo "Pushing to gh-pages branch..."
git push origin gh-pages

echo "Switching back to main branch..."
cd ../my-website

echo "Deployment complete!"

