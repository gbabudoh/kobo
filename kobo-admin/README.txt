DEPLOYMENT INSTRUCTIONS
=======================

1. Upload this entire 'kobo-admin' folder to your VPS.

2. Open your terminal on the VPS and navigate to this folder:
   cd kobo-admin

3. Install the required tools (run once):
   npm install

4. Start the server (runs on port 3000):
   node index.js

   (To keep it running in the background, use: pm2 start index.js --name kobo-admin)

5. Open your browser:
   http://109.205.181.195:3000/
