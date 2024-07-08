declare namespace passwdUser {
	interface UserData {
		username: string;
		password: string;

		/**
		Also known as [UID](https://en.wikipedia.org/wiki/User_identifier).
		*/
		userIdentifier: number;

		/**
		Also known as [GID](https://en.wikipedia.org/wiki/Group_identifier).
		*/
		groupIdentifier: number;

		/**
		Name of user.
		*/
		fullName: string;

		/**
		Home directory.
		*/
		homeDirectory: string;

		/**
		Default shell.
		*/
		shell: string;
	}
}


declare const passwdUser: {
	/**
	Get the [passwd](https://en.wikipedia.org/wiki/Passwd) user entry from a username or [user identifier (UID)](https://en.wikipedia.org/wiki/User_identifier_(Unix)).

	@param username - The username or the [user identifier (UID)](https://en.wikipedia.org/wiki/User_identifier) to look up. Default: [`process.getuid()`](https://nodejs.org/api/process.html#process_process_getuid) (The current user).

	@example
	```
	import passwdUser = require('passwd-user');

	(async () => {
		console.log(await passwdUser('sindresorhus'));
		// {
		// 	username: 'sindresorhus',
		// 	password: '*',
		// 	userIdentifier: 501,
		// 	groupIdentifier: 20,
		// 	fullName: 'Sindre Sorhus',
		// 	homeDirectory: '/home/sindresorhus',
		// 	shell: '/bin/zsh'
		// }

		await passwdUser(501);
		console.log('Got entry for user 501');

		const user = await passwdUser();
		console.log(`Got entry for user ${user.userIdentifier}`);
	})();
	```
	*/
	(username?: string | number): Promise<passwdUser.UserData | undefined>;

	/**
	Synchronously get the [passwd](https://en.wikipedia.org/wiki/Passwd) user entry from a username or [user identifier (UID)](https://en.wikipedia.org/wiki/User_identifier_(Unix)).

	@param username - The user name or the [user identifier (UID)](https://en.wikipedia.org/wiki/User_identifier) to look up. Default: [`process.getuid()`](https://nodejs.org/api/process.html#process_process_getuid) (The current user).

	@example
	```
	import passwdUser = require('passwd-user');

	console.log(passwdUser.sync('sindresorhus'));
	// {
	// 	username: 'sindresorhus',
	// 	password: '*',
	// 	userIdentifier: 501,
	// 	groupIdentifier: 20,
	// 	fullName: 'Sindre Sorhus',
	// 	homeDirectory: '/home/sindresorhus',
	// 	shell: '/bin/zsh'
	// }

	passwdUser.sync(501);
	console.log('Got entry for user 501');

	const user = passwdUser.sync();
	console.log(`Got entry for user ${user.userIdentifier}`);
	```
	*/
	sync(username?: string | number): passwdUser.UserData | undefined;
};

export = passwdUser;
