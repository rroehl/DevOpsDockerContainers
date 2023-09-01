import jenkins.model.Jenkins
import java.util.logging.LogManager
import hudson.model.User 
import jenkins.model.*
import hudson.security.*
/* Jenkins home directory */ 
def jenkinsHome = Jenkins.instance.getRootDir().absolutePath
def logger = LogManager.getLogManager().getLogger("")
/* Replace the Key and value with the values you want to set.*/
/* System.setProperty(key, value) ALSO SET IN THE JAVA paramters*/
System.setProperty("jenkins.install.runSetupWizard", "false")
System.setProperty("jenkins.security.ApiTokenProperty.adminCanGenerateNewTokens", "true")
logger.info("Jenkins Startup Script: Successfully updated the system properties value for jenkins.security.ApiTokenProperty.adminCanGenerateNewTokens and jenkins.install.SetupWizard.adminInitialApiToken. Script location : ${jenkinsHome}/init.groovy.d ")
