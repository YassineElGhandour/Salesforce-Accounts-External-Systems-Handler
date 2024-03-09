# Accounts Links Handler for both incoming and outcoming requests to external applications
The objective of this project is to handle incoming account links from an external party, and insert them in a salesforce organization according to the requirements, then post the account links that have been succesfully mapped with existing accounts under a different 3rd application

# Requirements
Please makes sure that git and sfdx are installed, and update sfdx to the latest version
> sfdx update

# Installation
Go to SFDX project location
> cd AccountHandler

Check all orgs
> sfdx force:org:list

Login to dev hub
> sfdx auth:web:login -d -a DevHub

Create scratch org
> sfdx force:org:create -s -f config/project-scratch-def.json -a "AccountHandlerScratchOrg" 

Convert to unmanaged code
> sfdx force:source:convert

Deploy unmanaged code
> ssfdx force:source:push -u AccountHandlerScratchOrg

Open specific scratch org
> sfdx force:org:open -u AccountHandlerScratchOrg
