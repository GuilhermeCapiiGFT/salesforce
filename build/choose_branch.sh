if [[ -n ${CIRCLE_PR_NUMBER} ]]
then
curl -L "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64" \
  -o jq
chmod +x jq
url="https://api.github.com/repos/$ORG/$PROJECT/pulls/$CIRCLE_PR_NUMBER?access_token=$GITHUB_TOKEN"
target_branch=$(
  curl "$url" | ./jq '.base.ref' | tr -d '"'
)
fi
echo "Target Branch: $target_branch";