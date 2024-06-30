<!-- markdownlint-disable MD032 MD033 MD041 --->

<div align="center">
    <a href="https://github.com/TuxTechLab/TuxTechIaaC">
        <img src="https://avatars.githubusercontent.com/tuxthebot" width="30%">
        <h1>
            TuxTechIaaC
        </h1>
    </a>
</div>

[TuxTechLab-Infrastructure-as-a-Code](ttps://github.com/TuxTechLab/TuxTechIaaC), in-short **`TuxTechIaaC`** is repository for CNCF applications to be used in deployments


## Getting Started

- 🌟 **Download TuxTechIaaC from github**

    ```bash
    git clone https://github.com/TuxTechLab/TuxTechIaaC.git   
    ```
-  🌟 **How To Start Document Server**

    1. The docusaurus webserver source is inside `www/tuxtechiaac`.
    2. Start the Docusaurus node.js local developmentt server, use supplied in [scripts](./scripts/) folder to start the local server for both Windows and Linux. But require administrative privillages. Before firing the Docusaurus server start script, MAKE SURE to CHECK ENVIRONEMENT DEPENDENCIES ARE PASSING. Else Docusaurus server might cause unnecessary issues.

        - **`For Linux`**
        
            Please use `Bash` shell to avoid unnecessary errors/ failures **with sudo privillages**.
            ```bash
            cd 'scripts\'

            # Check Current Dependencies are Passing
            "./check_docusaurus_dependencies.ps1"

            # Check Local Deploment Script Help Function
            './manage_docusaurus_server.ps1' --help

            # Local Deploment Script Start Docusaurus Server
            "./manage_docusaurus_server.ps1" --start

            # Local Deploment Script Stop Docusaurus Server
            # WIP : Need to fix the functionality of STOP
            "./manage_docusaurus_server.ps1" --stop
            ```
    
        - **`For Windows`**

            Please use `PowerShell` to avoid unnecessary errors/ failures **with Administrative Privillages**.
            ```bash
            cd scripts/


            # Local Deploment Script Help Function
            ./manage_docusaurus_server.sh --help

            # Local Deploment Script Start The Docusaurus Server
            manage_docusaurus_server.sh --start

            # Local Deploment Script Stop The Docusaurus Server
            manage_docusaurus_server.sh --stop
            ```

- Laucnth browser and hit `http://localhost:3000` to access the development server.


## Security

1. As this repo helps to deploy CNCF application on multi-cloud. Hence there is a very urgent requirement of security and secret management.
2. For Security We Want to use GPG signed commits in this repo. Currently still the setup GPG key is facing issues. Will put a documentation on how to setup GPG signed Git Commit for Windows, Mac, Linux environments.
3. **Also environment variables/ secrects for running application will be shared using demo secrects**. And request anyone who plans to use this solution, to generate/ use their own unique strong password/ secrets. DO NOT USE DEMO ENV SECRETS in Production.