# passwd-user [![Build Status](https://travis-ci.org/sindresorhus/passwd-user.svg?branch=master)](https://travis-ci.org/sindresorhus/passwd-user)

> Get the [passwd](https://en.wikipedia.org/wiki/Passwd) user entry from a username or [user identifier (UID)](https://en.wikipedia.org/wiki/User_identifier_(Unix))

Works on macOS and Linux. See [`user-info`](https://github.com/sindresorhus/user-info) if you need cross-platform support.


## Install

```
$ npm install passwd-user
```


## Usage

```js
const passwdUser = require('passwd-user');

(async () => {
	console.log(await passwdUser('sindresorhus'));
	/*
	{
		username: 'sindresorhus',
		password: '*',
		userIdentifier: 501,
		groupIdentifier: 20,
		fullName: 'Sindre Sorhus',
		homeDirectory: '/home/sindresorhus',
		shell: '/bin/zsh'
	}
	*/

	await passwdUser(501);
	console.log('Got entry for user 501');

	const user = await passwdUser();
	console.log(`Got entry for user ${user.userIdentifier}`);
})();
```


## API

Returns an object with:

- `username`
- `password`
- `userIdentifier`: [UID](https://en.wikipedia.org/wiki/User_identifier)
- `groupIdentifier`: [GID](https://en.wikipedia.org/wiki/Group_identifier)
- `fullName`: Name of user
- `homeDirectory`: Home directory
- `shell`: Default shell

### passwdUser([username | userIdentifier])

Returns a `Promise<object>` with the user entry.

### passwdUser.sync([username | userIdentifier])

Returns an `object` with the user entry.

#### username

Type: `string`

The username to look up.

#### userIdentifier

Type: `number`<br>
Default: [`process.getuid()`](https://nodejs.org/api/process.html#process_process_getuid) (The current user)

The [user identifier (UID)](https://en.wikipedia.org/wiki/User_identifier) to look up.


## Related

- [username](https://github.com/sindresorhus/username) - Get the user's username *(cross-platform)*
- [fullname](https://github.com/sindresorhus/fullname) - Get the user's fullname *(cross-platform)*


## License

MIT © [Sindre Sorhus](https://sindresorhus.com)
