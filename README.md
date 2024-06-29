# Infrastructure-As-Code

TuxTechLab-Infrastructure-as-a-Code, in-short TuxTechIaaC is repository for CNCF applications to be used in deployments


## Documents

> 🌟 **How To Start Document Server**

1. Goto inside `web/TuxTechIaaC`.
2. Start the node.js server from using *ANY* of the commands 1-4 mentioned in the comments below.
    ```bash
    cd web/TuxTechIaaC/
    npm start       # 1. Starts the development server.
    npm run build   # 2. Bundles your website into static files for production.
    npm run serve   # 3. Serves the built website locally.
    npm run deploy  # 4. Publishes the website to GitHub pages.
    ```
3. Goto  Browser and hit `http://localhost:3000` to access the development server.


## Security

1. As this repo helps to deploy CNCF application on multi-cloud. Hence there is a very urgent requirement of security and secret management.
2. For Security We Want to use GPG signed commits in this repo. Currently still the setup GPG key is facing issues. Will put a documentation on how to setup GPG signed Git Commit for Windows, Mac, Linux environments.
3. Also environment variables/ secrects for running application will be shared using demo secrects. And request anyone who plans to use this solution, to generate/ use their own unique strong password/ secrets. DO NOT USE DEMO ENV SECRETS in Production.