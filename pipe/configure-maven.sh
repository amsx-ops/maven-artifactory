#!/bin/bash

# required parameters
ARTIFACTORY_URL=${ARTIFACTORY_URL:?'ARTIFACTORY_URL variable missing.'}
ARTIFACTORY_USER=${ARTIFACTORY_USER:?'ARTIFACTORY_USER variable missing.'}
ARTIFACTORY_PASSWORD=${ARTIFACTORY_PASSWORD:?'ARTIFACTORY_PASSWORD variable missing.'}
MAVEN_SNAPSHOT_REPO=${MAVEN_SNAPSHOT_REPO:?'MAVEN_SNAPSHOT_REPO variable missing.'}
MAVEN_RELEASE_REPO=${MAVEN_RELEASE_REPO:?'MAVEN_RELEASE_REPO variable missing.'}


cat <<EOF >./settings.xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.1.0 http://maven.apache.org/xsd/settings-1.1.0.xsd" xmlns="http://maven.apache.org/SETTINGS/1.1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <servers>
        <server>
            <username>${ARTIFACTORY_USER}</username>
            <password>${ARTIFACTORY_PASSWORD}</password>
            <id>central</id>
        </server>
        <server>
            <username>${ARTIFACTORY_USER}</username>
            <password>${ARTIFACTORY_PASSWORD}</password>
			<id>snapshots</id>	
		</server>
	</servers>
	<profiles>
		<profile>
			<id>artifactory</id>
			<repositories>
				<repository>
					<snapshots>
						<enabled>false</enabled>
					</snapshots>
					<id>central</id>
					<name>libs-release</name>
					<url>${ARTIFACTORY_URL}/${MAVEN_RELEASE_REPO}</url>
				</repository>
				<repository>
					<snapshots/>
					<id>snapshots</id>
					<name>libs-snapshot</name>
					<url>${ARTIFACTORY_URL}/${MAVEN_SNAPSHOT_REPO}</url>
				</repository>
			</repositories>
			<pluginRepositories>
				<pluginRepository>
					<snapshots>
						<enabled>false</enabled>
					</snapshots>
					<id>central</id>
					<name>libs-release</name>
					<url>${ARTIFACTORY_URL}/${MAVEN_SNAPSHOT_REPO}</url>
				</pluginRepository>
				<pluginRepository>
					<snapshots/>
					<id>snapshots</id>
					<name>libs-snapshot</name>
					<url>${ARTIFACTORY_URL}/${MAVEN_RELEASE_REPO}</url>
				</pluginRepository>
			</pluginRepositories>			
		</profile>		
	</profiles>
	<activeProfiles>
		<activeProfile>artifactory</activeProfile>
	</activeProfiles>
</settings>
EOF