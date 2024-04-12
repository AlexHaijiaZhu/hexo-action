#!/bin/sh
###
 # @Author: Alex Zhu hjzhu@uvic.ca
 # @Date: 2024-04-12 15:32:58
 # @LastEditors: Alex Zhu hjzhu@uvic.ca
 # @LastEditTime: 2024-04-12 15:34:47
 # @FilePath: \Ferryd:\Documents\GitHub\hexo-action\entrypoint.sh
 # @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
### 

set -e

# setup ssh-private-key
mkdir -p /root/.ssh/
echo "$INPUT_DEPLOY_KEY" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

# setup deploy git account
git config --global user.name "$INPUT_USER_NAME"
git config --global user.email "$INPUT_USER_EMAIL"

# install hexo env
npm install hexo-cli -g
npm install hexo-deployer-git --save

# deployment
if [ "$INPUT_COMMIT_MSG" = "none" ]
then
    hexo g --deploy
elif [ "$INPUT_COMMIT_MSG" = "" ] || [ "$INPUT_COMMIT_MSG" = "default" ]
then
    # pull original publish repo
    NODE_PATH=$NODE_PATH:$(pwd)/node_modules node /sync_deploy_history.js
    hexo g --deploy
else
    NODE_PATH=$NODE_PATH:$(pwd)/node_modules node /sync_deploy_history.js
    hexo g --deploy -m "$INPUT_COMMIT_MSG"
fi

echo ::set-output name=notify::"Deploy complate."