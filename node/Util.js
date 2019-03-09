class Util {
	static getRandomDelay(max = 30) {
		return Math.floor(Math.random() * max) + 1;
	}
}

module.exports = Util;
