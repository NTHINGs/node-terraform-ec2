wget https://gist.githubusercontent.com/NTHINGs/6249e4352657004659ec0ec50ed9f1ed/raw/a1cd1cd8669922eafec6f8d3ea1ec7751eec0697/index.js
chmod +x index.js 
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install 8
npm install pm2 -g
pm2 start index.js