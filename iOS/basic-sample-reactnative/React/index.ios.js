'use strict';

var React = require('react-native');
var {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Image,
  NavigatorIOS,
  TouchableHighlight,
} = React;

var WelcomeView = require('./welcome-view');

require('NativeModules').LockReact.init({});

var ReactNativeSample = React.createClass({
  render: function() {
    return (
      <NavigatorIOS style={styles.navigator}
        initialRoute={{
          component: WelcomeView,
          title: 'Welcome to Auth0',
        }}
      />
    );
  }
});

var styles = StyleSheet.create({
  navigator: {
    flex: 1,
  },
});

AppRegistry.registerComponent('ReactNativeSample', () => ReactNativeSample);
