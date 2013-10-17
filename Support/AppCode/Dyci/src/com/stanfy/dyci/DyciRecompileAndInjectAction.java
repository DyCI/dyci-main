package com.stanfy.dyci;

import com.intellij.openapi.actionSystem.AnAction;
import com.intellij.openapi.actionSystem.AnActionEvent;
import com.intellij.openapi.actionSystem.PlatformDataKeys;
import com.intellij.openapi.diagnostic.Logger;
import com.intellij.openapi.fileEditor.FileDocumentManager;
import com.intellij.openapi.ui.MessageType;
import com.intellij.openapi.ui.popup.Balloon;
import com.intellij.openapi.ui.popup.JBPopupFactory;
import com.intellij.openapi.vfs.VirtualFile;
import com.intellij.openapi.wm.StatusBar;
import com.intellij.openapi.wm.WindowManager;
import com.intellij.ui.awt.RelativePoint;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Created with IntelliJ IDEA.
 * User: paultaykalo
 * Date: 3/5/13
 * Time: 8:06 AM
 * LLC Stanfy, All Rights Reserved.
 */
public class DyciRecompileAndInjectAction extends AnAction{

  static final Logger LOG = Logger.getInstance(DyciRecompileAndInjectAction.class);

  @Override
  public void actionPerformed(final AnActionEvent actionEvent) {

    // Resolving current file that was selected in active window
//        Project project = actionEvent.getData(PlatformDataKeys.PROJECT);
    VirtualFile currentFile = actionEvent.getData(PlatformDataKeys.VIRTUAL_FILE);

    // Check if current virtual file is not null
    if (currentFile == null) {
      this.showMessageBubble(actionEvent, MessageType.ERROR, "Cannot run injection. Incorrect file specified");
      return;
    }

    String path = currentFile.getCanonicalPath();

    // Injection
    this.injectFile(actionEvent, path);


  }

  private void injectFile(final AnActionEvent actionEvent, final String path) {

    // FileD
//        Project project = actionEvent.getData(PlatformDataKeys.PROJECT);
//        FileDocumentManager.getInstance().saveDocument();

    FileDocumentManager.getInstance().saveAllDocuments();

    // Let's run our script!
    // Script location is ~/.dyci/dyci-recompile.py
    final String USER_HOME = System.getProperty("user.home");
    final String dyciScriptLocation = USER_HOME + "/.dyci/scripts/dyci-recompile.py";
    final File dyciScriptLocationFile = new File(dyciScriptLocation);
    LOG.info("Dyci file location is " + dyciScriptLocationFile.getAbsolutePath());

    if (!dyciScriptLocationFile.exists()) {
      this.showMessageBubble(actionEvent, MessageType.ERROR, "Cannot run injection. No Dyci scripts were found. Make sure, that you've ran install.sh");
      return;
    }

    Runtime rt = Runtime.getRuntime();
    String[] commands = {dyciScriptLocation, path};
    try {
      Process proc = rt.exec(commands);

      BufferedReader stdInput = new BufferedReader(new
          InputStreamReader(proc.getInputStream()));

      BufferedReader stdError = new BufferedReader(new
          InputStreamReader(proc.getErrorStream()));

      // read the output from the command
      StringBuilder standardOutput = new StringBuilder();
      StringBuilder errorOutput = new StringBuilder();
      String s;
      while ((s = stdInput.readLine()) != null) {
        standardOutput.append(s);
      }

      // read any errors from the attempted command
      while ((s = stdError.readLine()) != null) {
        errorOutput.append(s);
      }

      // All is OK!
      if (proc.exitValue() == 0) {
        this.showMessageBubble(actionEvent, MessageType.INFO, "File "+ path + " was successfully injected\n" + standardOutput.toString());
      } else {
        this.showMessageBubble(actionEvent, MessageType.ERROR, "File "+ path + " was not injected successfully\n" + errorOutput.toString());
      }

    } catch (IOException e) {
      LOG.error("Exception on script run : " + e.getMessage());
      this.showMessageBubble(actionEvent, MessageType.ERROR, "Failed to run injection script");
    }
  }


  /**
   * Shows Error bubble
   * @param actionEvent was passed via action Performed
   * @param messageType type of balloon
   * @param message that will be shown
   */
  private void showMessageBubble(final AnActionEvent actionEvent, final MessageType messageType, final String message) {

    StatusBar statusBar = WindowManager.getInstance()
        .getStatusBar(actionEvent.getData(PlatformDataKeys.PROJECT));


    JBPopupFactory.getInstance()
        .createHtmlTextBalloonBuilder(message, messageType, null)
        .setFadeoutTime(7500)
        .createBalloon()
        .show(RelativePoint.getCenterOf(statusBar.getComponent()),
            Balloon.Position.atRight);
  }
}
