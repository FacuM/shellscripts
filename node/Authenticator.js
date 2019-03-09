const { writeFile } = require('fs');
const { createInterface } = require('readline');

module.exports = class {
	static authorize(client) {
		return new Promise((resolve) => {
			resolve(this.getAccessToken(client));
		});
	}

	static getAccessToken(client) {
		const authenticateURL = client.generateAuthUrl({
			scope: ['https://www.googleapis.com/auth/drive'],
			response_type: 'code',
			access_type: 'offline'
		});

		console.info(`Authorize the CLI by visiting: ${authenticateURL}`);
		const readline = createInterface({
			input: process.stdin,
			output: process.stdout
		});

		readline.question('Enter the code from the page here: ', (code) => {
			readline.close();
			client.getToken(code, (error, token) => {
				if (error) throw `Error retrieving access token.\n${error}`;
				client.setCredentials(token);
				this.saveToken(token);
			});
		});
	}

	static saveToken(token) {
		writeFile('token.json', JSON.stringify(token), (error) => {
			if (error) throw error;
			console.log('Token has been saved. Please rerun the CLI.');
			process.exit(0);
		});
	}

};
