# Accounts Links Handler for both incoming and outcoming requests to externall applications
The objective of this project is to handle incoming accounts from an external party, and insert them in a salesforce organization, then republish them under a public REST API endpoint hosted on salesforce side

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
