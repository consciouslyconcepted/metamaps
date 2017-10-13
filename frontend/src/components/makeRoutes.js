import React from 'react'
import { Route, IndexRoute } from 'react-router'
import App from './App'
import Apps from './Apps'
import Maps from './Maps'
import MapView from './MapView'
import Notifications from './Notifications'
import TopicView from './TopicView'

function nullComponent(props) {
  return null
}

export default function makeRoutes (currentUser) {
  const homeComponent = currentUser && currentUser.id ? Maps : nullComponent
  return <Route path="/" component={App} >
    <IndexRoute component={homeComponent} />
    <Route path="explore">
      <Route path="active" component={Maps} />
      <Route path="featured" component={Maps} />
      <Route path="mine" component={Maps} />
      <Route path="shared" component={Maps} />
      <Route path="starred" component={Maps} />
      <Route path="mapper/:id" component={Maps} />
    </Route>
    <Route path="maps/:id">
      <IndexRoute component={MapView} />
      <Route path="conversation" component={MapView} />
      <Route path="request_access" component={nullComponent} />
    </Route>
    <Route path="topics/:id" component={TopicView} />
    <Route path="login" component={nullComponent} />
    <Route path="join" component={nullComponent} />
    <Route path="request" component={nullComponent} />
    <Route path="notifications">
      <IndexRoute component={Notifications} />
      <Route path=":id" component={Notifications} />
    </Route>
    <Route path="users">
      <Route path=":id/edit" component={nullComponent} />
      <Route path="password/new" component={nullComponent} />
      <Route path="password/edit" component={nullComponent} />
    </Route>
    <Route path="metacodes">
      <IndexRoute component={nullComponent} />
      <Route path="new" component={nullComponent} />
      <Route path=":id/edit" component={nullComponent} />
    </Route>
    <Route path="metacode_sets">
      <IndexRoute component={nullComponent} />
      <Route path="new" component={nullComponent} />
      <Route path=":id/edit" component={nullComponent} />
    </Route>
    <Route path="oauth">
      <Route path="token/info" component={Apps} />
      <Route path="authorize">
        <IndexRoute component={Apps} />
        <Route path=":code" component={Apps} />
      </Route>
      <Route path="authorized_applications">
        <IndexRoute component={Apps} />
        <Route path=":id" component={Apps} />
      </Route>
      <Route path="applications">
        <IndexRoute component={Apps} />
        <Route path="new" component={Apps} />
        <Route path=":id" component={Apps} />
        <Route path=":id/edit" component={Apps} />
      </Route>
    </Route>
  </Route>
}
