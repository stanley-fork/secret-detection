# secret-detection

secret-detection is a static code analysis tool designed for parsing various common data formats in search of hardcoded credentials and sensitive information. secret-detection can run in the CLI, Docker, or you can integrate it in your CI/CD pipeline.

### Welcome to join in and feel free to contribute.

## Features
* Using regex rules to scan, and help identify the following types of secrets:
    * API Keys
    * AWS Keys
    * OAuth Client Secrets
    * SSH Private Keys
    * GitHub/GitLab Personal Access Tokens
    * Docker Hub Tokens
    * And many more...
* Supports whitelisting files
* Supports custom rules
* Lightweight
* Easy to customize to your needs
* Docker support for easy deployment and CI/CD integration 

## Requirements

- Python 3.x (for local usage)
- Docker (optional, for containerized usage)

## Installation

### Local Installation
No additional dependencies required - uses only Python standard library.

### Docker Installation
Build the Docker image:
```bash
docker build -t secret-detection:latest .
```

## Usage

### Local Usage

```bash
python3 secret-detection.py --rule /path/to/pattern.json --path /path/to/scan
```

**Example:**
```bash
python3 secret-detection.py --rule pattern.json --path test/
```

### Docker Usage

#### Basic Docker Run
```bash
# Scan a directory (mount the directory as a volume)
docker run --rm \
  -v /path/to/scan:/scan \
  -v $(pwd)/pattern.json:/app/pattern.json \
  secret-detection:latest \
  --rule pattern.json --path /scan
```

**Example: Scan the test directory**
```bash
docker run --rm \
  -v $(pwd)/test:/scan \
  -v $(pwd)/pattern.json:/app/pattern.json \
  secret-detection:latest \
  --rule pattern.json --path /scan
```

#### Using Docker Compose

1. Place the directory you want to scan in `./scan-target/` (or modify `docker-compose.yml` to point to your directory)

2. Run the scan:
```bash
docker-compose run secret-detection --rule pattern.json --path /scan
```

**Note:** You can also use Docker Compose with a custom path by modifying the volume mount in `docker-compose.yml` or using `docker run` directly.

### Command Line Options

- `-r, --rule`: Path to the JSON file containing regex patterns (default: `./pattern.json`)
- `-p, --path`: Path to the directory or file to scan

### Ignored Files

The ignored list contains patterns for filenames that you want to skip during scanning. Default ignored patterns:
```python
ignored = [
    'node_modules', 'bower_components', '.sass-cache', 
    '.png', '.ico', '.mov', '.jpeg', 'jpg', '.avi', 
    '.gif', '.apk', '.exe', '.jar', '.dmg', '.pdf', 
    '.ipa', '.svg'
]
```

You can modify the `ignored` list in `secret-detection.py` to customize which files/directories are skipped.

## OUTPUT
```Filepath: test/test.txt : Line 14
Reason: API KEY

<string name="newrelic_key">HSUFAHSIUYCd7491274LFCAdgdsdgdgdgasdg</string>
~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~
Filepath: test/test.txt : Line 18
Reason: Sendgrid API

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
~~~~~~~~~~~~~~~~~~~~~


~~~~~~~~~~~~~~~~~~~~~
Filepath: test/test.txt : Line 20
Reason: Sendgrid API

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
~~~~~~~~~~~~~~~~~~~~~

```

## CI/CD Integration

This project includes pre-configured CI/CD workflow files for easy integration:

### GitHub Actions

Two workflow files are available in `.github/workflows/`:

1. **`secret-detection.yml`** - Uses Docker (recommended)
   - Automatically runs on push, pull requests, and can be scheduled
   - Builds the Docker image and scans the repository
   - Uploads scan results as artifacts

2. **`secret-detection-python.yml`** - Uses Python directly
   - No Docker required
   - Faster startup time
   - Same triggers and artifact uploads

**To use:**
- Copy the workflow file(s) to your repository's `.github/workflows/` directory
- The workflows will automatically run on push/PR to main/master/develop branches
- You can also trigger them manually via GitHub Actions UI

**Custom GitHub Actions Workflow:**
```yaml
- name: Run secret detection
  run: |
    docker build -t secret-detection:latest .
    docker run --rm \
      -v ${{ github.workspace }}:/scan \
      -v ${{ github.workspace }}/pattern.json:/app/pattern.json \
      secret-detection:latest \
      --rule pattern.json --path /scan
```

### GitLab CI

A pre-configured `.gitlab-ci.yml` file is included:

- Automatically runs on branches and merge requests
- Uses Docker-in-Docker service
- Uploads scan results as artifacts
- Configured to not fail the pipeline (reports findings without blocking)

**To use:**
- The `.gitlab-ci.yml` file is already in the repository root
- GitLab will automatically detect and run it
- Ensure your GitLab runner has Docker support enabled

**Custom GitLab CI Configuration:**
```yaml
secret-detection:
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t secret-detection:latest .
    - docker run --rm -v $(pwd):/scan -v $(pwd)/pattern.json:/app/pattern.json secret-detection:latest --rule pattern.json --path /scan
```

### Other CI/CD Platforms

**Jenkins Example:**
```groovy
stage('Secret Detection') {
    steps {
        sh '''
            docker build -t secret-detection:latest .
            docker run --rm \
                -v ${WORKSPACE}:/scan \
                -v ${WORKSPACE}/pattern.json:/app/pattern.json \
                secret-detection:latest \
                --rule pattern.json --path /scan
        '''
    }
}
```

**Local CI/CD Integration:**

You can also run the tool directly in your CI/CD pipeline if Python is available:
```bash
python3 secret-detection.py --rule pattern.json --path /path/to/scan
```  

## Customization

### Custom Pattern Rules

You can create your own pattern file by modifying `pattern.json`. The file should contain a JSON object where:
- **Key**: Description of the secret type
- **Value**: Regex pattern to match the secret

Example:
```json
{
    "Custom API Key": "api_key['\"]?[:=]?['\"]?([a-zA-Z0-9]{32,})",
    "My Secret Pattern": "your-regex-pattern-here"
}
```

## Roadmap / Wish List
1. JSON Output format
2. Entropy-based detection
3. Git integration (pre-commit hooks)
4. Integration with BurpSuite/ZAP/Jenkins/SonarQube
5. Support for more secret types
6. ...

## License
### This project is licensed under the terms of the MIT license.
