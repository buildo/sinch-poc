import React from 'react';
import { /*t, */props } from 'tcomb-react';
import { pure, skinnable } from 'revenge';
import { FlexView as View } from 'Basic';
import SinchClient from 'sinch-rtc';

@pure
@skinnable()
@props({
})
export default class VideoCall extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
      videoSrc: null,
      incomingVideoSrc: null,
      caller: 'dani',
      callee: 'gabro',
      callListeners: {
        onCallProgressing: console.log('DRRIIIIIIN'),
        onCallEstablished: call => this.setState({ incomingVideoSrc: call.incomingStreamURL }),
        onCallEnded: () => this.setState({ incomingVideoSrc: null, call: null })
      },
      call: null
    };

    this.sinchClient = new SinchClient({
      applicationKey: 'a08df457-78e8-4bd5-bb95-c93ce2d25c1e',
      capabilities: { messaging: true, calling: true, video: true },
      supportActiveConnection: true
    });

    // sinchClient.newUser({ username: 'dani', password: 'dani' }).then(::console.log);

  }

  onPlaceCall = () => {
    // this.sinchClient.start({ username: this.state.caller, password: this.state.caller })
    this.sinchClient.start({ userTicket: 'eyJhcHBsaWNhdGlvbktleSI6ImEwOGRmNDU3LTc4ZTgtNGJkNS1iYjk1LWM5M2NlMmQyNWMxZSIsImlkZW50aXR5Ijp7InR5cGUiOiJ1c2VybmFtZSIsImVuZHBvaW50IjoiZ2Ficm8ifSwiY3JlYXRlZCI6IjIwMTYtMDUtMjZUMTQ6Mzc6MDkuNTM3WiIsImV4cGlyZXNJbiI6ODY0MDB9:xvB89FXgjBpZUz0YoXXt6GpAg/TGsQlyDQ8DGUgqJx8=' })
      .then(() => {
        this.sinchClient.startActiveConnection();
        const callClient = this.callClient = this.sinchClient.getCallClient();
        callClient.initStream().then(stream => {
          const videoSrc = window.URL.createObjectURL(stream);
          this.setState({ videoSrc });
        });
        callClient.addEventListener({
          onIncomingCall: call => {
            call.answer();
            call.addEventListener(this.state.callListeners);
            this.setState({ call });
          }
        });
        const call = this.callClient.callUser(this.state.callee);
        call.addEventListener(this.state.callListeners);
        this.setState({ call });
      })
      .fail(::console.log);
  };

  getLocals() {
    const {
      onPlaceCall,
      state: { videoSrc, incomingVideoSrc, call, callee, caller }
    } = this;

    const isCallOngoing = !!call;

    return { videoSrc, incomingVideoSrc, onPlaceCall, isCallOngoing, callee, caller };
  }

  template({ videoSrc, incomingVideoSrc, onPlaceCall, isCallOngoing }) {
    return (
      <View column className='video-call' height={400} width={400}>
        {/*<input placeholder='caller' type='text' value={caller} onChange={({ target: { value: caller } }) => this.setState({ caller })} />
        <input placeholder='callee' type='text' value={callee} onChange={({ target: { value: callee } }) => this.setState({ callee })} />*/}
        {videoSrc && <video muted src={videoSrc} autoPlay style={{ height: 400, width: 400 }} />}
        {incomingVideoSrc && <video src={incomingVideoSrc} autoPlay style={{ height: 400, width: 400 }} />}
        {!isCallOngoing && <button onClick={onPlaceCall}>CALL</button>}
      </View>
    );
  }

}
