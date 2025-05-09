#!/bin/bash

INTERFACE="ens33"       # 网卡名称
BASE_DELAY=$((RANDOM % 100 + 1))          # 初始延迟（ms）
FIXED_STEP=10          # 固定步长（ms）
MAX_DELAY=500          # 最大延迟（ms）
SLEEP_TIME=6           # 每次循环间隔（秒）

current_delay=$BASE_DELAY
current_step=$FIXED_STEP

# 初始化 tc 规则（使用 replace 避免重复添加）
tc qdisc replace dev $INTERFACE root netem delay ${current_delay}ms

while true; do
    # 计算新延迟
    new_delay=$((current_delay + current_step))
    
    # 边界检测
    if [ $new_delay -ge $MAX_DELAY ]; then
        new_delay=$MAX_DELAY
        current_step=-$FIXED_STEP  # 到达上限后反向
    elif [ $new_delay -le 0 ]; then
        new_delay=0
        current_step=$FIXED_STEP    # 到达下限后反向
    fi
    
    # 更新延迟
    tc qdisc change dev $INTERFACE root netem delay ${new_delay}ms
    echo "Current delay: ${new_delay}ms"
    
    current_delay=$new_delay
    sleep $SLEEP_TIME
done
