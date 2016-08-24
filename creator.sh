#!/bin/sh
set -e

SCRIPT_NAME=${0##*/}
EXAMPLE="Example: sh $SCRIPT_NAME ~/Developer/NewApp"

COL_RESET="\x1b[39;49;00m"

echo_error(){
    COL_RED="\x1b[31;01m"
    echo $COL_RED$1$COL_RESET
}

echo_green(){
    COL_GREEN="\x1b[32;01m"
    echo $COL_GREEN$1$COL_RESET
}

if [ "$#" == 1 ] && ([ "$1" == "-h" ] || [ "$1" == "-?" ] || [ "$1" == "--help" ]); then
    echo "Usage: sh $SCRIPT_NAME [path_to_folder_with_new_app] [organization_name] [ios_version_min]"
    echo_green "$EXAMPLE"
    echo
    echo "Option\t\tGNU long option\t\tMeaning"
    echo "-h, -?\t\t--help\t\t\tShow this message"
    exit 1
elif [ "$#" != 1 ]; then
    echo_error "Illegal number of parameters"
    echo_green "$EXAMPLE"
    exit 1
fi

declare -a TEMPLATES_APP_NAME=(
"EmptyObjCApp"
)
echo "\t1) With DVAppCore"
printf "Enter your Template type(1, 2, ...) and press [ENTER]: "
read TEMPLATE_TYPE
if [ "$TEMPLATE_TYPE" == "" ]; then
    echo_error "Template type can't be blank"
    exit 1
elif ( ! [[ $TEMPLATE_TYPE =~ ^[[:digit:]]$ ]] || [ "$TEMPLATE_TYPE" == "0" ] || (( $TEMPLATE_TYPE > ${#TEMPLATES_APP_NAME[*]} )) ); then
    echo_error "Illegal number of parameters"
    exit 1
fi

printf "Enter your Organization Name and press [ENTER]: "
read ORGANIZATION_NAME
if [ "$ORGANIZATION_NAME" == "" ]; then
    echo_error "Organization Name can't be blank"
    exit 1
fi

printf "Enter your Organization Identifier and press [ENTER]: "
read ORGANIZATION_IDENTIFIER
if [ "$ORGANIZATION_IDENTIFIER" == "" ]; then
    echo_error "Organization Identifier can't be blank"
    exit 1
fi

printf "Enter min iOS version and press [ENTER]: "
read IOS_VERSION_MIN

if [ "$IOS_VERSION_MIN" == "" ]; then
    echo_error "Min iOS version can't be blank"
    exit 1
elif [[ $IOS_VERSION_MIN =~ ^[[:digit:]]$ ]]; then
    IOS_VERSION_MIN="${IOS_VERSION_MIN}.0"
elif ! [[ $IOS_VERSION_MIN =~ ^[[:digit:]].[[:digit:]]$ ]]; then
    echo_error "Min iOS version: [number].[number]"
    exit 1
fi

MY_FULL_NAME=$(finger `whoami` | awk -F: '{ print $3 }' | head -n1 | sed 's/^ //')
CURRENT_DATE=$(date "+%d\/%m\/%y")
CURRENT_YEAR=$(date "+%Y")

NEW_APP_LOCATION=$1
NEW_APP_NAME=$(basename $NEW_APP_LOCATION)
NEW_APP_DIR_PATH=$(dirname $NEW_APP_LOCATION)

TEMPLATE_APP_NAME="${TEMPLATES_APP_NAME["($TEMPLATE_TYPE-1)"]}"

TEMPLATE_APP_PATH=$(cd "$(dirname "$0")"; pwd)
TEMPLATE_ORGANIZATION_NAME="vandv"
TEMPLATE_ORGANIZATION_IDENTIFIER="com.${TEMPLATE_ORGANIZATION_NAME}"

echo
echo "Path to new app:\t\t$NEW_APP_LOCATION"
echo "New app name:\t\t\t$NEW_APP_NAME"
echo "Organization Name:\t\t$ORGANIZATION_NAME"
echo "Organization Identifier:\t$ORGANIZATION_IDENTIFIER"
echo "Bundle Identifier:\t\t${ORGANIZATION_IDENTIFIER}.${NEW_APP_NAME}"
echo "iOS version min:\t\t$IOS_VERSION_MIN"
echo

printf "Continue creating new app? [y/n]: "
read IS_CONTINUE_CREATING

if [ "$IS_CONTINUE_CREATING" != "y" ]; then
    exit 1
fi

echo
echo "Start script"
echo
echo "copy $TEMPLATE_APP_PATH to $NEW_APP_LOCATION started"
echo

cp -R "$TEMPLATE_APP_PATH/." $NEW_APP_LOCATION
find $NEW_APP_LOCATION -name '*.DS_Store' -type f -delete
#rm -rf "$NEW_APP_LOCATION/.git"

echo
echo copy template finished

mv "$NEW_APP_LOCATION/$TEMPLATE_APP_NAME" "$NEW_APP_LOCATION/$NEW_APP_NAME"
mv "$NEW_APP_LOCATION/${TEMPLATE_APP_NAME}.xcodeproj" "$NEW_APP_LOCATION/${NEW_APP_NAME}.xcodeproj"
mv "$NEW_APP_LOCATION/${TEMPLATE_APP_NAME}Tests" "$NEW_APP_LOCATION/${NEW_APP_NAME}Tests"
mv "$NEW_APP_LOCATION/${NEW_APP_NAME}Tests/${TEMPLATE_APP_NAME}Tests.m" "$NEW_APP_LOCATION/${NEW_APP_NAME}Tests/${NEW_APP_NAME}Tests.m"

declare -a PATH_FOR_REPLACEMENT=(
"${NEW_APP_NAME}/Controllers/ViewController.h"
"${NEW_APP_NAME}/Controllers/ViewController.m"
"${NEW_APP_NAME}/Other/AppDelegate.h"
"${NEW_APP_NAME}/Other/AppDelegate.m"
"${NEW_APP_NAME}/Resources/en.lproj/Localizable.strings"
"${NEW_APP_NAME}/SupportingFiles/App-Prefix.pch"
"${NEW_APP_NAME}/SupportingFiles/Info.plist"
"${NEW_APP_NAME}/SupportingFiles/main.m"
"${NEW_APP_NAME}Tests/${NEW_APP_NAME}Tests.m"
"${NEW_APP_NAME}.xcodeproj/project.pbxproj"
)
declare -a RULES_OF_REPLACEMENT=(
"${TEMPLATE_APP_NAME}/${NEW_APP_NAME}"
"USER_NAME/${MY_FULL_NAME}"
"CURRENT_DATE/${CURRENT_DATE}"
"CURRENT_YEAR/${CURRENT_YEAR}"
"COMPANY_NAME/${ORGANIZATION_NAME}"
)
for path in "${PATH_FOR_REPLACEMENT[@]}"
do
    for rule_replacement in "${RULES_OF_REPLACEMENT[@]}"
    do
        sed -i "" -e "s/$rule_replacement/g" "$NEW_APP_LOCATION/$path"
    done
done

declare -a PBXPROJ_RULES_OF_REPLACEMENT=(
"${TEMPLATE_ORGANIZATION_IDENTIFIER}/${ORGANIZATION_IDENTIFIER}"
"${TEMPLATE_ORGANIZATION_NAME}/${ORGANIZATION_NAME}"
"IPHONEOS_DEPLOYMENT_TARGET *= *[[:digit:]].[[:digit:]];/IPHONEOS_DEPLOYMENT_TARGET = $IOS_VERSION_MIN;"
)
for pbxproj_rule_replacement in "${PBXPROJ_RULES_OF_REPLACEMENT[@]}"
do
    sed -i "" -e "s/$pbxproj_rule_replacement/g" "$NEW_APP_LOCATION/${NEW_APP_NAME}.xcodeproj/project.pbxproj"
done

declare -a DIRECTORIES_FOR_DELETING=(
"$NEW_APP_LOCATION/${NEW_APP_NAME}.xcodeproj/project.xcworkspace"
"$NEW_APP_LOCATION/${NEW_APP_NAME}.xcodeproj/xcuserdata"
)
for path_directory in "${DIRECTORIES_FOR_DELETING[@]}"
do
    if [ -d "$path_directory" ]; then
    rm -rf $path_directory
    fi
done

echo "Prepared all data"

POD_FILE_SOURCE="platform :ios, '$IOS_VERSION_MIN'\n\ntarget '$NEW_APP_NAME' do\n\tpod 'DVAppCore', :git => 'https://github.com/denis-vashkovski/DVAppCore.git'\nend\n\ntarget '${NEW_APP_NAME}Tests' do\n\nend"
echo $POD_FILE_SOURCE > "$NEW_APP_LOCATION/Podfile"

echo "Created Podfile"
echo

pod --project-directory=$NEW_APP_LOCATION install

WORKSPACE_FULL_PATH="$NEW_APP_LOCATION/${NEW_APP_NAME}.xcworkspace"
if [ -d "$WORKSPACE_FULL_PATH" ]; then
open -a Xcode $WORKSPACE_FULL_PATH
fi

echo
echo "End script"
