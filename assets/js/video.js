import Player from "./player";
import {Presence} from "phoenix";

let Video = {

  init(socket, element) {
    if (!element) { return; }

    let playerId = element.getAttribute("data-player-id");
    let videoId = element.getAttribute("data-id");

    socket.connect();

    Player.init(
      element.id,
      playerId,
      () => {
        this.onReady(videoId, socket);
      }
    );
  },

  onReady(videoId, socket) {
    let msgContainer = document.getElementById("msg-container");
    let msgInput = document.getElementById("msg-input");
    let postButton = document.getElementById("msg-submit");
    let userList = document.getElementById("user-list");
    let lastSeenId = 0;
    let videoChannel = socket.channel("videos:" + videoId, () => {
      return { last_seen_id: lastSeenId };
    });

    let presence = new Presence(videoChannel);
    presence.onSync(
      () => {
        // To iterate users, we use the presences.list() function which accepts a
        // callback.The callback will be called for each presence item with 2
        // arguments, the presence id and a list of metas(one for each presence for
        // that presence id).We use this to display the users and the number of
        // devices they are online with.
        userList.innerHTML = presence.list(
          (id, { user: user, metas: [first, ...rest] }) => {
            let count = rest.length + 1;
            return `<li>${user.username}: (${count})</li>`;
          }
        ).join("");
      }
    );

    // When the Post button is clicked, get the message body of the input field,
    // and the current timecode of the video playback.
    //
    // Then fire off a "new_annotation" event and push it to the server.
    //
    // Finally, manually clear the message input field so the user can make
    // a new annotation.
    postButton.addEventListener("click", _event => {
      let payload = {
        body: msgInput.value,
        at: Player.getCurrentTime()
      };

      videoChannel.push("new_annotation", payload)
        .receive("error", event => console.log("Error adding new annotation.", event));

      msgInput.value = "";
    });

    msgContainer.addEventListener("click", e => {
      e.preventDefault();
      let seconds = e.target.getAttribute("data-seek") ||
          e.target.parentNode.getAttribute("data-seek");

      if (!seconds) {
        return;
      }

      Player.seekTo(seconds);
    });

    // Handle incoming events published to us from the server.
    videoChannel.on("new_annotation", (response) => {
      lastSeenId = response.id;
      this.renderAnnotation(msgContainer, response);
    });

    videoChannel.join()
      .receive("ok", ({annotations}) => {
        let ids = annotations.map(a => a.id);
        if (ids.length > 0) {
          lastSeenId = Math.max(...ids);
        }
        this.scheduleMessages(msgContainer, annotations);
      })
      .receive("error", reason => console.log("failed to join the video channel", reason));

  },

  scheduleMessages(msgContainer, annotations) {
    clearTimeout(this.scheduletimer);

    this.scheduleTimer = setTimeout(() => {
      let currentTime = Player.getCurrentTime();
      let remaining = this.renderAtTime(annotations, currentTime, msgContainer);
      this.scheduleMessages(msgContainer, remaining);
    }, 1000);
  },

  renderAtTime(annotations, seconds, msgContainer) {
    return annotations.filter(
      annotation => {
        if (annotation.at > seconds) {
          return true;
        } else {
          this.renderAnnotation(msgContainer, annotation);
          return false;
        }
      }
    );
  },

  renderAnnotation(msgContainer, {user, body, at}) {
    let template = document.createElement("div");

    template.innerHTML = `
      <a href="#" data-seek="${this.escapeInput(at)}">
        [${this.formatTime(at)}]
        <b>${this.escapeInput(user.username)}</b>: ${this.escapeInput(body)}
      </a>
      `;

    msgContainer.appendChild(template);
    msgContainer.scrollTop = msgContainer.scrollHeight;
  },

  formatTime(at) {
    let date = new Date(null);
    date.setSeconds(at / 1000);
    return date.toISOString().substr(14, 5);
  },

  escapeInput(userInputString) {
    let div = document.createElement("div");
    div.appendChild(document.createTextNode(userInputString));
    return div.innerHTML;
  }
};

export default Video;
