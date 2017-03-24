#!/bin/bash

Cyan='\033[0;36m'
Default='\033[0;m'

version=""
repoName=""
confirmed="n"

getVersion() {
    read -p "请输入版本号: " version

    if test -z "$version"; then
        getVersion
    fi
}

getRepoName() {
    read -p "请输入仓库名: " repoName

    if test -z "$repoName"; then
        getRepoName
    fi
}

getInfomation() {
getVersion
getRepoName

echo -e "\n${Default}================================================"
echo -e "  Version  :  ${Cyan}${version}${Default}"
echo -e "  RepoName :  ${Cyan}${repoName}${Default}"
echo -e "================================================\n"
}

echo -e "\n"
while [ "$confirmed" != "y" -a "$confirmed" != "Y" ]
do
if [ "$confirmed" == "n" -o "$confirmed" == "N" ]; then
getInfomation
fi
read -p "确定? (y/n):" confirmed
done

git add .
git commit -m "update to repo"
git tag $version
git push
git push --tags
pod repo push $repoName --allow-warnings --use-libraries
say "finished"
echo "finished"
