#!/usr/bin/env bash
# download_mysql_connector.sh
# Download MySQL Connector/J from Maven Central into ./jars and copy to repo root.
# Usage: ./download_mysql_connector.sh [version]
# Example: ./download_mysql_connector.sh 8.0.33

set -euo pipefail
VERSION_DEFAULT="8.0.33"

# Allow either: ./download_mysql_connector.sh [version]
# Or: ./download_mysql_connector.sh --local /path/to/mysql-connector.jar
if [ "${1:-}" = "--local" ]; then
	if [ -z "${2:-}" ]; then
		echo "Usage: $0 --local /path/to/mysql-connector-java.jar" >&2
		exit 2
	fi
	LOCAL_PATH="$2"
	if [ ! -f "$LOCAL_PATH" ]; then
		echo "Local file not found: $LOCAL_PATH" >&2
		exit 2
	fi
	VERSION="local"
else
	VERSION="${1:-$VERSION_DEFAULT}"
fi

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)/.."
JARS_DIR="$REPO_ROOT/jars"

mkdir -p "$JARS_DIR"

JAR_NAME="mysql-connector-java-${VERSION}.jar"

if [ "${VERSION}" = "local" ]; then
	echo "Copying local jar to $JARS_DIR and repo root"
	cp "$LOCAL_PATH" "$JARS_DIR/$JAR_NAME"
	cp "$JARS_DIR/$JAR_NAME" "$REPO_ROOT/$JAR_NAME"
	echo "Copied: $JARS_DIR/$JAR_NAME"
	exit 0
fi

echo "Downloading MySQL Connector/J version: $VERSION"

# Candidate download URLs (try each until one works)
declare -a URLS
URLS=(
  "https://repo1.maven.org/maven2/mysql/mysql-connector-java/${VERSION}/${JAR_NAME}"
  "https://search.maven.org/remotecontent?filepath=mysql/mysql-connector-java/${VERSION}/${JAR_NAME}"
  "https://repo1.maven.org/maven2/com/mysql/mysql-connector-java/${VERSION}/${JAR_NAME}"
  "https://search.maven.org/remotecontent?filepath=com/mysql/mysql-connector-java/${VERSION}/${JAR_NAME}"
  "https://repo1.maven.org/maven2/mysql/mysql-connector-j/${VERSION}/mysql-connector-j-${VERSION}.jar"
  "https://search.maven.org/remotecontent?filepath=mysql/mysql-connector-j/${VERSION}/mysql-connector-j-${VERSION}.jar"
)

SUCCESS=0
for url in "${URLS[@]}"; do
	echo "Trying: $url"
	if curl -L --fail -o "$JARS_DIR/$JAR_NAME" "$url"; then
		echo "Downloaded from: $url"
		SUCCESS=1
		break
	else
		echo "Failed: $url"
		# remove partial file
		[ -f "$JARS_DIR/$JAR_NAME" ] && rm -f "$JARS_DIR/$JAR_NAME"
	fi
done

if [ "$SUCCESS" -ne 1 ]; then
	echo "All download attempts failed. Please manually download the Connector/J jar from:" >&2
	echo "  https://dev.mysql.com/downloads/connector/j/" >&2
	echo "Or place an existing jar into the ./jars/ directory and re-run this script with --local /path/to/jar" >&2
	exit 1
fi

# Also copy to repo root for convenience
cp "$JARS_DIR/$JAR_NAME" "$REPO_ROOT/$JAR_NAME"

echo "Downloaded to: $JARS_DIR/$JAR_NAME"
echo "Also copied to repository root: $REPO_ROOT/$JAR_NAME"

echo "Done. You can now run your script or spark-submit with the jar available."