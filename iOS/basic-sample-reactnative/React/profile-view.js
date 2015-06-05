'use strict';

var React = require('react-native');

var {
  StyleSheet,
  Text,
  View,
  Image,
  TouchableHighlight,
  AlertIOS,
} = React;

var API_ENDPOINT = 'http://localhost:3001/secured/ping';

var ProfileView = React.createClass({
  render: function() {
    return (
      <View style={styles.container}>
        <View style={styles.messageBox}>
          <Image
            style={styles.badge}
            source={require('image!badge')}
          />
          <Image
            style={styles.avatar}
            source={{uri: this.props.profile.picture}}
          />
          <Text style={styles.title}>Welcome {this.props.profile.name}</Text>
        </View>
        <TouchableHighlight 
          style={styles.callApiButton}
          underlayColor='#949494'
          onPress={this._onCallApi}>
          <Text>Call API</Text>
        </TouchableHighlight>
      </View>
    );
  },
  _onCallApi: function() {
    fetch(API_ENDPOINT)
      .then((response) => response.text())
      .then((responseText) => {
        AlertIOS.alert('We got the secured data successfully', null, [{text: 'Ok'}]);
      })
      .catch((error) => {
        AlertIOS.alert('Please download the API seed so that you can call it', null, [{text: 'Ok'}]);
      });
  },
});

var styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    backgroundColor: '#15204C',
  },
  messageBox: {
    flex: 1,
    justifyContent: 'center',
  },
  badge: {
    alignSelf: 'center',
    height: 110,
    width: 102,
    marginBottom: 80,
  },
  avatar: {
    alignSelf: 'center',
    height: 128,
    width: 240,
  },
  title: {
    fontSize: 17,
    textAlign: 'center',
    marginTop: 20,
    color: '#FFFFFF',
  },
  callApiButton: {
    height: 50,
    alignSelf: 'stretch',
    backgroundColor: '#D9DADF',
    margin: 10,
    borderRadius: 5,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

module.exports = ProfileView;