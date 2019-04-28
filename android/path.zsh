case $OS_NAME in
  Linux )
    export ANDROID_HOME="$HOME/Android/Sdk";
    export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/"
    ;;
  Darwin )
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home"
    export ANDROID_HOME="$HOME/Library/Android/sdk";
    ;;
esac
export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/28.0.3:$PATH"
