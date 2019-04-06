case `uname` in
  Linux )
    export ANDROID_HOME="$HOME/Android/sdk";
    export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/bin/"
    ;;
  Darwin )
    export JAVA_HOME=$(/usr/libexec/java_home)
    export ANDROID_HOME="$HOME/Library/Android/sdk";
    ;;
esac
export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/28.0.3:$PATH"
