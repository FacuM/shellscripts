const Client = require('./Client');

const drive = new Client(JSON.parse(require('fs').readFileSync(`${process.cwd()}/credentials.json`)).drive);

drive.on('ready', () => {
	const [command, argument] = process.argv.slice(2);

	switch (command) {
		case 'help' || '-help' || '-h':
			logHelpMessage();
			break;
		case 'upload' || '-upload' || '-u':
			if (!argument) return console.error('Requires the file name.');
			drive.uploadFile(argument);
			break;
		case 'list' || '-list' || '-l':
			drive.listFiles();
			break;
		case 'share' || '-share' || '-s':
			if (!argument) return console.error('Requires the file ID, use the list command.');
			drive.shareFile(argument);
			break;
		default:
			logHelpMessage(true);
	}

	function logHelpMessage(unknowCommand) {
		console.log(`${unknowCommand ? 'Command not found.' : ''}
  Here's the list of available commands:
  upload: uploads a file
  share: share the file, requires file ID
  list: lists all the available files with their IDs`);
	}
});

