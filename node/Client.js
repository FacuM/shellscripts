const { promisify } = require('util');
const { google: Google } = require('googleapis');
const { getType } = require('mime');

const Authenticator = require('./Authenticator');
const { getRandomDelay } = require('./Util');
var { readFile, createReadStream } = require('fs');
readFile = promisify(readFile);

module.exports = class extends require('events').EventEmitter {
	constructor({ clientID, clientSecret, redirectURL }) {
		super();
		this.client = new Google.auth.OAuth2(clientID, clientSecret, redirectURL);
		this.initiate();
		this.busy = false;
	}

	initiate() {
		readFile(`${process.cwd()}/token.json`).then(token => {
			this.client.setCredentials(JSON.parse(token));
			this.drive = Google.drive({ version: 'v3', auth: this.client });
			this.emit('ready');
		}).catch(() => {
			Authenticator.authorize(this.client);
		});
	}

	listFiles(pageSize = 10) {
		this.drive.files.list({
			pageSize,
			fields: 'nextPageToken, files(id, name)'
		}, (error, result) => {
			if (error) return console.log(`The API returned an error: ${error}`);
			const { files } = result.data;
			if (files.length) {
				console.log('Files:');
				files.forEach(file => {
					console.log(`${file.name} (${file.id})`);
				});
			} else console.log('No files found.');
		});
	}

	uploadFile(file) {
		this.drive.files.create({
			resource: {
				name: file
			},
			media: {
				mimeType: getType(file),
				body: createReadStream(file)
			},
			fields: 'id'
		}, (error, { data }) => {
			if (error && error.code === 403 && !this.busy) {
				const delay = getRandomDelay();
				console.info(`We hit a ratelimit, trying again in ${delay} seconds`);
				this.busy = true;
				setTimeout(() => {
					this.uploadFile(file);
					this.busy = false;
				}, delay * 1000);
			} else console.log('File ID: ', data.id);
		});
	}

	shareFile(fileId) {
		this.drive.permissions.create({
			fileId,
			resource: {
				role: 'reader',
				type: 'anyone'
			}
		}, (error, { status }) => {
			if (error || status !== 200) throw error;
			console.info(`https://drive.google.com/uc?id=${fileId}&export=download`);
		});
	}
};
