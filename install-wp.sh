#!/bin/bash

##############################################
#  Install wp in current directory           #
#   *Set up wordpress, and if you want a db  #
#   *Installs riiskit                        #
#   *User chooses what plugins to install    #
##############################################
# author halvard@mekom.no

### Prerequisits ####
# YOU NEED TO HAVE WP-CLI INSTALLED
# YOU NEED TO HAVE THE MYSQL IN PATH ROUTED TO THE ONE YOU USE
#
# Something like this:
# mysql() {
#     /Applications/MAMP/Library/bin/mysql "$@"
# }
# mysqladmin() {
#     /Applications/MAMP/Library/bin/mysqladmin "$@"
# }
# export -f mysql
# export -f mysqladmin

#TODO:
#
# Better error handling on inputs
# Better readability when running things, especially wp-cli commands
# Test plugins, find new ones, make groups so that the user dont have to 
#   press so many buttons
# Add Debugging to wp-config
# What other settings should be set
# Should we load dummy content? Let the user decide?
# Woocommerce?


#####################
#  HelperFunctions  #
#####################
##Used to display error messages
function error {
    echo "ERROR: $1"
    echo "Aborting"
    exit $?
}

#Display success messages
function success {
    echo "Success: $1"
}
function createDatabase {
    echo "Creating DATABSE, need some info!"
    echo "Hostname:"
    read DBHOST
    echo "Username:"
    read DBUSER
    echo "Password:"
    read DBPWD
    echo "Database name:"
    read DBNAME
    echo "Creating DB"
    if `mysql -h $DBHOST -u $DBUSER -p$DBPWD -e "CREATE DATABASE $DBNAME"`; then
         success "Database $DBNAME created"
         createConfig $DBNAME $DBUSER $DBPWD $DBHOST
     else
        error "Database creation failed."
     fi 
}
function getDatabase {
    echo "I gotta know what your db details are!"
    echo "Creating DATABSE, need some info!"
    echo "NBNBNBNB!!!"
    echo "You NEED to have your MAMP MySQL in path for this to work"
    echo "NBNBNBNB!!!"
    echo "Hostname:"
    read DBHOST
    echo "Username:"
    read DBUSER
    echo "Password:"
    read DBPWD
    echo "Database name:"
    read DBNAME
    createConfig $DBNAME $DBUSER $DBPWD $DBHOST
}

function createConfig {
echo ">>>>>Creating wp-config"
echo `wp core config --dbname=$1 --dbuser=$2 --dbpass=$3 --dbhost=$4 --locale=nb_NO`
}

#Show a spinner after long running processes
#Usage: "(long-running-command) & spinner $!""
spinner()
{
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

#####################
#   wp-cli config   #
#####################

#Test if WP CLI is installed
if `wp > /dev/null`; then
    echo "Ready to go!"
else 
    error "WP CLI needs to be installed and configured from http://wp-cli.org/"
fi
echo "path: `pwd`" > "wp-cli.local.yml"

#Create wp cli config from user input
echo "Give me the title of the website!"
read TITLE
echo "Title is set to: $TITLE!"
#write to and create config 
echo "title: $TITLE" >> "wp-cli.local.yml"

echo "Present to me the url that shall be used! (http://localhost:8000)"
read URL
echo "Url set to $URL!"
#write to config
echo "url: $URL" >> "wp-cli.local.yml"

echo "Your (user)name mortal?!"
read USER
echo "Username set to $USER!"
#write to config
echo "user: $USER" >> "wp-cli.local.yml"

echo "Your Password?!"
read PWD

echo "Electronic mail address if you please:"
read ADMMAIl

#####################
#   Wordpress core  #
#####################

#download latest wordpress in norwegian
echo "Downloading and installing wordpress - norwegian"
echo ">>>>Downloading"
echo `wp core download --locale=nb_NO`

echo ">>>>Removing extra themes and plugins"
# Remove themes that are unwanted, keeping one for fallback
`rm -rf wp-content/themes/twentyfourteen`
`rm -rf wp-content/themes/twentythirteen`
# Remove unused plugins
`rm -rf wp-content/plugins/hello.php`
`rm -rf wp-content/plugins/akismet`

echo "#####################"
echo "#   Database setup  #"
echo "#####################"

read -p "Want to set up a new database? (y/n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
    then
    createDatabase
else
    getDatabase
fi

echo `wp core install --title=$TITLE --admin_user=$USER --admin_password=$PWD --admin_email=$ADMMAIl`


echo "#####################"
echo "#      Themes       #"
echo "#####################"

#Get riiskit
echo ">>>>Riiskitting the wp install"
echo `wp theme install https://github.com/Chrisriis/riiskit/archive/master.zip --activate`


#####################
#      Plugins      #
#####################
echo "##################"
echo "# Choose Plugins #"
echo "##################"

read -p "WP Importer? (y/n)" -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]
    then
    echo "Installing and activating"
    echo `wp plugin install https://downloads.wordpress.org/plugin/wordpress-importer.zip --activate`
fi

read -p ">>>>>Automattic developer?(y/n)" -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]
    then
    echo "Installing and activating"
echo `wp plugin install https://github.com/Automattic/developer/archive/master.zip --activate`
fi

read -p ">>>>>WP-debugbar?(y/n)" -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]
    then
    echo "Installing and activating"
echo `wp plugin install https://github.com/wpplex/wp-debugbar/archive/master.zip --activate`
fi

read -p ">>>>>Log viewer? (y/n)" -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]
    then
    echo "Installing and activating"
echo `wp plugin install https://downloads.wordpress.org/plugin/log-viewer.zip --activate`
fi

read -p ">>>>>Force regen thumbnails?(y/n)" -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]
    then
    echo "Installing and activating"
echo `wp plugin install https://github.com/wp-plugins/force-regenerate-thumbnails/archive/master.zip --activate`
fi

read -p ">>>>>User switching? (y/n)" -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]
    then
    echo "Installing and activating"
echo `wp plugin install https://github.com/crowdfavorite-mirrors/wp-user-switching/archive/master.zip --activate`
fi

read -p ">>>>>Yoast? (y/n)" -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]
    then
    echo "Installing and activating"
echo `wp plugin install https://github.com/Yoast/wordpress-seo/archive/trunk.zip --activate`
fi

echo ">>>>>WP Retina"F-4TV31278RN611611D
read -p "WP Importer? (y/n)" -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]
    then
    echo "Installing and activating"
echo `wp plugin install https://github.com/wp-plugins/wp-retina-2x/archive/master.zip --activate`
fi

read -p ">>>>>EWWW image optimizer? (y/n)" -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]
    then
    echo "Installing and activating"
    echo `wp plugin install https://github.com/wp-plugins/ewww-image-optimizer/archive/master.zip --activate`
fi

read -p ">>>>>Duplicate post? (y/n)" -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]
    then
    echo "Installing and activating"
    echo `wp plugin install https://downloads.wordpress.org/plugin/duplicate-post.zip --activate`
fi

#ACF is a bit harder, but we can do it
read -p ">>>>>ACF PRO? (y/n)" -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]
    then
    echo "Installing and activating"
    # get acf zip file
    echo `wget -O wp-content/plugins/acf-pro.zip "http://connect.advancedcustomfields.com/index.php?p=pro&a=download&k=b3JkZXJfaWQ9NDI2MjZ8dHlwZT1kZXZlbG9wZXJ8ZGF0ZT0yMDE0LTEwLTIyIDExOjA5OjE1"`
    # install & activate acf
    echo `wp plugin install wp-content/plugins/acf-pro.zip -–activate`
    # remove zip file
    `rm -rf wp-content/plugins/acf-pro.zip`
fi