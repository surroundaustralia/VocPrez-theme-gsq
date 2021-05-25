eval $(cat .env | tr -d '\r')

echo "Styles"
echo "copying $VP_THEME_HOME/style content to $VP_HOME/vocprez/view/style"
cp $VP_THEME_HOME/style/* $VP_HOME/vocprez/view/style

echo "Templates"
echo "copying $VP_THEME_HOME/templates content to $VP_HOME/vocprez/view/templates"
cp $VP_THEME_HOME/templates/* $VP_HOME/vocprez/view/templates

echo "Config"
echo "creating VocPrez config with $VP_THEME_HOME/config.py"
echo "Alter config.py to include variables"
sed 's#$SPARQL_ENDPOINT#'"$SPARQL_ENDPOINT"'#' $VP_THEME_HOME/config.py > $VP_THEME_HOME/config_updated.py
if [ -z "$SPARQL_USERNAME" ]
then
      sed -i 's#$SPARQL_USERNAME#None#' $VP_THEME_HOME/config_updated.py
else
      sed -i 's#$SPARQL_USERNAME#'\"$SPARQL_USERNAME\"'#' $VP_THEME_HOME/config_updated.py
fi
if [ -z "$SPARQL_PASSWORD" ]
then
      sed -i 's#$SPARQL_PASSWORD#None#' $VP_THEME_HOME/config_updated.py
else
      sed -i 's#$SPARQL_PASSWORD#'\"$SPARQL_PASSWORD\"'#' $VP_THEME_HOME/config_updated.py
fi
sed -i 's#$SYSTEM_BASE_URI#'"$SYSTEM_BASE_URI"'#' $VP_THEME_HOME/config_updated.py
echo "Move $VP_THEME_HOME/config.py to $VP_HOME/vocprez/_config/__init__.py"
mv $VP_THEME_HOME/config_updated.py $VP_HOME/vocprez/_config/__init__.py

echo "adding /vocabulary/ endpoint to app.py"
if `grep -q "@app.route(\"/vocabulary/\")" "$VP_HOME/vocprez/app.py"`; then
    echo "already there"
else
    sed -i 's#/vocab/#/vocabulary/#' $VP_HOME/vocprez/app.py
fi

echo "customisation done"
