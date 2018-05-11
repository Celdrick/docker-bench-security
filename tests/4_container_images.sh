#!/bin/sh

images=$(docker images -q)

check_4() {
  logit "\n"
  info "4 - 容器镜像和构建文件"
}

# 4.1
check_4_1() {
  check_4_1="4.1  - 创建容器的用户"
  totalChecks=$((totalChecks + 1))

  # If container_users is empty, there are no running containers
  if [ -z "$containers" ]; then
    info "$check_4_1"
    info "     * No containers running"
    logjson "4.1" "INFO"
    currentScore=$((currentScore + 0))
  else
    # We have some containers running, set failure flag to 0. Check for Users.
    fail=0
    # Make the loop separator be a new-line in POSIX compliant fashion
    set -f; IFS=$'
  '
    for c in $containers; do
      user=$(docker inspect --format 'User={{.Config.User}}' "$c")

      if [ "$user" = "User=" -o "$user" = "User=[]" -o "$user" = "User=<no value>" ]; then
        # If it's the first container, fail the test
        if [ $fail -eq 0 ]; then
          warn "$check_4_1"
          warn "     * Running as root: $c"
          logjson "4.1" "WARN: $c"
          fail=1
        else
          warn "     * Running as root: $c"
          logjson "4.1" "WARN: $c"
        fi
      fi
    done
    # We went through all the containers and found none running as root
    if [ $fail -eq 0 ]; then
        pass "$check_4_1"
        logjson "4.1" "PASS"
        currentScore=$((currentScore + 1))
    else
        currentScore=$((currentScore - 1))
    fi
  fi
  # Make the loop separator go back to space
  set +f; unset IFS
}

# 4.2
check_4_2() {
  check_4_2="4.2  - 容器使用可信的基础镜像"
  totalChecks=$((totalChecks + 1))
  note "$check_4_2"
  logjson "4.2" "NOTE"
  currentScore=$((currentScore + 0))
}

# 4.3
check_4_3() {
  check_4_3="4.3  - 容器中不安装没有必要的软件包"
  totalChecks=$((totalChecks + 1))
  note "$check_4_3"
  logjson "4.3" "NOTE"
  currentScore=$((currentScore + 0))
}

# 4.4
check_4_4() {
  check_4_4="4.4  - 扫描镜像漏洞并且构建包含安全补丁的镜像"
  totalChecks=$((totalChecks + 1))
  note "$check_4_4"
  logjson "4.4" "NOTE"
  currentScore=$((currentScore + 0))
}

# 4.5
check_4_5() {
  check_4_5="4.5  - 启用docker内容信任"
  totalChecks=$((totalChecks + 1))
  if [ "x$DOCKER_CONTENT_TRUST" = "x1" ]; then
    pass "$check_4_5"
    logjson "4.5" "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_4_5"
    logjson "4.5" "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# 4.6
check_4_6() {
  check_4_6="4.6  - 将HEALTHCHECK说明添加到容器镜像"
  totalChecks=$((totalChecks + 1))
  fail=0
  for img in $images; do
    if docker inspect --format='{{.Config.Healthcheck}}' "$img" 2>/dev/null | grep -e "<nil>" >/dev/null 2>&1; then
      if [ $fail -eq 0 ]; then
        fail=1
        warn "$check_4_6"
        logjson "4.6" "WARN"
      fi
      imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
      if ! [ "$imgName" = '[]' ]; then
        warn "     * No Healthcheck found: $imgName"
        logjson "4.6" "WARN: $imgName"
      fi
    fi
  done
  if [ $fail -eq 0 ]; then
    pass "$check_4_6"
    logjson "4.6" "PASS"
    currentScore=$((currentScore + 1))
  else
    currentScore=$((currentScore - 1))
  fi
}

# 4.7
check_4_7() {
  check_4_7="4.7  - 不在dockerfile中单独使用更新命令"
  totalChecks=$((totalChecks + 1))
  fail=0
  for img in $images; do
    if docker history "$img" 2>/dev/null | grep -e "update" >/dev/null 2>&1; then
      if [ $fail -eq 0 ]; then
        fail=1
        info "$check_4_7"
        logjson "4.7" "INFO"
      fi
      imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
      if ! [ "$imgName" = '[]' ]; then
        info "     * Update instruction found: $imgName"
      fi
    fi
  done
  if [ $fail -eq 0 ]; then
    pass "$check_4_7"
    logjson "4.7" "PASS"
    currentScore=$((currentScore + 1))
  else
    currentScore=$((currentScore + 0))
  fi
}

# 4.8
check_4_8() {
  check_4_8="4.8  - 镜像中删除setuid和setgid权限"
  totalChecks=$((totalChecks + 1))
  note "$check_4_8"
  logjson "4.8" "NOTE"
  currentScore=$((currentScore + 0))
}

# 4.9
check_4_9() {
  check_4_9="4.9  - 在dockerfile中使用copy而不是add"
  totalChecks=$((totalChecks + 1))
  fail=0
  for img in $images; do
    docker history "$img" 2> /dev/null | grep 'ADD' >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      if [ $fail -eq 0 ]; then
        fail=1
        info "$check_4_9"
        logjson "4.9" "INFO"
      fi
      imgName=$(docker inspect --format='{{.RepoTags}}' "$img" 2>/dev/null)
      if ! [ "$imgName" = '[]' ]; then
        info "     * ADD in image history: $imgName"
        logjson "4.9" "INFO: $imgName"
      fi
      currentScore=$((currentScore + 0))
    fi
  done
  if [ $fail -eq 0 ]; then
    pass "$check_4_9"
    logjson "4.9" "PASS"
    currentScore=$((currentScore + 1))
  fi
}

# 4.10
check_4_10() {
  check_4_10="4.10 - 秘密不存储在dockerfile"
  totalChecks=$((totalChecks + 1))
  note "$check_4_10"
  logjson "4.10" "NOTE"
  currentScore=$((currentScore + 0))
}

# 4.11
check_4_11() {
  check_4_11="4.11 - 仅安装已经验证的软件包"
  totalChecks=$((totalChecks + 1))
  note "$check_4_11"
  logjson "4.11" "NOTE"
  currentScore=$((currentScore + 0))
}
