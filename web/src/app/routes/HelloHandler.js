import React from 'react';
import { FlexView as View } from 'Basic';
import Logout from 'Logout/LogoutContainer';
import VideoCall from 'VideoCall/VideoCall';

export default class HelloHandler extends React.Component {

  render() {
    return (
      <View grow column height={100}>
        <VideoCall />
        <Logout />
      </View>
    );
  }

}
