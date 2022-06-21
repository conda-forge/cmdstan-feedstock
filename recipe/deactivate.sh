if [ "$CMDSTAN_OLD" ];
then
    export CMDSTAN="$CMDSTAN_OLD"
else
    unset CMDSTAN
fi
unset CMDSTAN_OLD
