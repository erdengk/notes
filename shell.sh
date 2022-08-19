now=$(date "+%Y-%m-%d-%H:%M")

git add ./
git commit -m "$now ：update"
git push origin main

echo "complete，in order to forever free"