# EnvReader

The EnvReader gem is a utility to manage and validate environment variables used in your project. It helps in reading, finding and validating the environment variables used in your project.

## Installation

Add the gem to your `Gemfile`:

```Gemfile
gem 'envreader'
```

Run `bundle install`

```bash
bundle install
```

OR

You can directly add it using `bundle add`

```bash
bundle add envreader
```

## Usage

The gem offers several features through its Command-Line Interface (CLI). You can use the commands listed below to find, read, and validate environment keys.

- ### CLI Commands

Run the script using one of the following options:

| Command                       | Description                                             |
| ----------------------------- | ------------------------------------------------------- |
| `-r, --read-keys [DIRECTORY]` | List all the environment keys used in a directory.      |
| `-f, --find-keys [DIRECTORY]` | Find all files and display their environment key usage. |
| `-v, --validate-keys`         | Validate environment keys and check for missing values. |
| `-e, --extensions x,y,z`      | Specify file extensions to scan (default: rb, erb).     |
| `-h, --help`                  | Display help for the available commands.                |

### Directly using in a rails directory

1. **Without passing directory and extensions**

   - List all the env variables used in the app
     ```bash
     envreader -r
     ```
   - Find the files where the variables are used
     ```
     envreader -f
     ```
   - Check if the env variables are set or missing and shows if valid or not
     ```
     envreader -v
     ```

2. **By passing directory and extension**

   ```bash
   envreader -f /path/to/directory -e rb, erb
   ```

   You can exclude either one or both directory or extension if not necessary. Additionally you can also use other commands to read, find and validate the keys.

3. **Optional Keys**

   Some keys are optional and may not need validation (e.g., CI, RAILS_ENV). You can modify the list of optional keys in the `optional_keys` method:

   To add custom optional keys during validation:

   ```
   envreader -v --optional-keys MY_CUSTOM_KEY,ANOTHER_KEY
   ```

4. **Help Menu**
   Run the `-h` or `--help` option to see the available commands.
   ```
   envreader -h
   ```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ShirajShrestha/envreader
