#!/bin/bash

################################################################################
#               Recherche de l'id d'une tablette                               #
#                dans le fichier de préchargement de l'inventaire              #
#                         dans JAMF Pro                                        #
#                                                                              #
#                                                                              #
# crée le : 24/07/2020                                                         #
# maj le : 24/07/2020                                                          #
#                                                                              #
# RaoulG1t - XP - HubiquIT                                                     #
#                                                                              #
################################################################################


#definition des variables
echo "Please enter your JSS Url :"
read Server
echo "Please enter your JSS Username :"
read JamfUser
echo "Please enter your JSS Password :"
read -s JamfPass
echo "Enter Serial Number to search :"
read SerialNumber
echo "Enter total of Line on preload Inventory :"
read Nline


#Creation du token Jamf API
LocalKey=`printf "$JamfUser:$JamfPass" | iconv -t ISO-8859-1 | base64 -i -`
#Demande du Token pour les JAMF API
`curl -X POST https://$Server/uapi/auth/tokens --header "authorization: Basic $LocalKey" -s --output mytoken.txt`

#Read mytoken.txt and get variable with good argument
OS_TOKEN=`cat mytoken.txt | grep "token" | awk '{printf $3}' | cut -c 2- | sed 's/.\{2\}$//'`
#rm ./mytoken.txt

curl -X GET "https://grandreims.jamfcloud.com/uapi/v1/inventory-preload?page=0&size=100&pagesize=100&page-size=$Nline&sort=id%3Aasc" -H "accept: application/json" -H "Authorization: Bearer $OS_TOKEN" -s --output preload.txt
cat preload.txt | grep -B 1 "$SerialNumber" > id.txt
GetId=`cat id.txt | grep "id" | awk '{printf $3}' | sed 's/.\{1\}$//'`
echo ""
echo "Your device $SerialNumber preload inventory Id : $GetId"

#Suppresion des Variables
unset OS_TOKEN
unset LocalKey
unset GetId

#Supression des fichiers Txt charger
rm ./*.txt
