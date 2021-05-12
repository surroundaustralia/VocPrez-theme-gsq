echo "prepare a deployment folder"
mkdir $VP_HOME/deploy
cp -r $VP_HOME/vocprez/* $VP_HOME/deploy

echo "copy GSQ style and templates to VocPrez deploy folder"
cp style/* $VP_HOME/deploy/view/style
cp templates/* $VP_HOME/deploy/view/templates

echo "set the VocPrez config"
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
mv $VP_THEME_HOME/config_updated.py $VP_HOME/deploy/_config/__init__.py

echo "adding /vocabulary/ endpoint to app.py"
if `grep -q "@app.route(\"/vocabulary/\")" "$VP_HOME/deploy/app.py"`; then
    echo "already there"
else
    sed -i 's#@app.route("/vocab/")#@app.route("/vocab/")\n@app.route("/vocabulary/")#' $VP_HOME/deploy/app.py
    sed -i 's#@app.route("/vocab/<string:vocab_id>/")#@app.route("/vocab/<string:vocab_id>/")\n@app.route("/vocabulary/<string:vocab_id>/")#' $VP_HOME/deploy/app.py
fi

echo "run Dockerfile there"
docker build -t vocprez-gsq -f $VP_HOME/Dockerfile $VP_HOME

echo "clean-up"
rm -r $VP_HOME/deploy

echo "complete"