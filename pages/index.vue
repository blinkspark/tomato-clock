<template>
  <div>
    <div class="hero is-fullheight" :class="heroClasses">
      <div class="hero-body">
        <div class="container has-text-centered">
          <div class="title is-size-2">{{timerText}}</div>
          <div class="columns">
            <div class="column">
              <button class="button" v-if="isIdle" @click="startBtn">开始</button>
              <button class="button" v-else-if="isCounting" @click="interuptBtn">打断</button>
              <button class="button" v-else disabled>开始</button>
              <button class="button" @click="settingBtn" v-if="isSetting">保存</button>
              <button class="button" @click="settingBtn" v-else>设置</button>
            </div>
          </div>
          <!-- columns1 -->
          <div class="colums" v-if="isSetting">
            <div class="column is-half is-offset-one-quarter">
              <div class="card has-text-left" style="padding:1rem 2rem">
                <div class="field">
                  <label class="label">专注时间</label>
                  <div class="control">
                    <input class="input" type="number" v-model="persist.focusMinites" />
                  </div>
                </div>
                <!-- focus -->
                <div class="field">
                  <label class="label">休息时间</label>
                  <div class="control">
                    <input class="input" type="number" v-model="persist.restMinutes" />
                  </div>
                </div>
                <!-- rest -->
                <label class="checkbox">
                  <input type="checkbox" v-model="persist.autoContinue" />
                  自动开始下一个番茄时间
                </label>
                <!-- auto continue -->
              </div>
            </div>
          </div>
          <!-- columns2 -->
        </div>
      </div>
    </div>
    <!-- hero -->
    <audio src="test.mp3" hidden ref="aud"></audio>
  </div>
</template>

<script>
const SEC = 1000;
const MIN = SEC * 60;
const EStatus = {
  COUNTING: "COUNTING",
  RESTING: "RESTING",
  IDLE: "IDLE"
};
export default {
  computed: {
    heroClasses() {
      return this.status === EStatus.COUNTING ? ["is-danger"] : ["is-success"];
    },
    isIdle() {
      return this.status === EStatus.IDLE;
    },
    isCounting() {
      return this.status === EStatus.COUNTING;
    }
  },
  data() {
    return {
      persist: {
        focusMinites: 25,
        restMinutes: 5,
        autoContinue: false
      },
      status: EStatus.IDLE,
      timerText: "番茄钟",
      targetTime: 0,
      isSetting: false
    };
  },
  methods: {
    tick() {
      let now = Date.now();
      let dur = this.targetTime - now;
      switch (this.status) {
        case EStatus.COUNTING:
          if (dur <= 0) {
            this.startRest();
            this.notify("恭喜，你完成了一个番茄时间！");
          }
          break;
        case EStatus.RESTING:
          if (dur <= 0) {
            this.startIdle();
            this.notify("休息好了，准备继续！");
            if (this.persist.autoContinue) {
              console.log("here");
              this.startCounting();
            }
          }
        default:
          break;
      }
      this.refreshTimerText();
    },
    refreshTimerText() {
      switch (this.status) {
        case EStatus.IDLE:
          this.timerText = `${this.persist.focusMinites}:00`;
          break;
        default:
          let now = Date.now();
          let dur = this.targetTime - now;
          let mins = Math.floor(dur / MIN);
          let secs = Math.floor((dur % MIN) / SEC);
          this.timerText = `${mins}:${secs >= 10 ? secs : "0" + secs}`;
          break;
      }
    },
    requesetPerm() {
      if (!("Notification" in window)) {
        alert("浏览器不支持通知！");
      } else if (window.Notification.permission === "default") {
        window.Notification.requestPermission();
      }
    },
    startBtn(e) {
      this.requesetPerm();
      this.startCounting();
    },
    interuptBtn(e) {
      this.startIdle();
    },
    settingBtn(e) {
      this.isSetting = !this.isSetting;
      if (this.isSetting === false) {
        this.save();
      }
    },
    startCounting() {
      this.targetTime = Date.now() + this.persist.focusMinites * MIN;
      this.status = EStatus.COUNTING;
    },
    startRest() {
      this.targetTime = Date.now() + this.persist.restMinutes * MIN;
      this.status = EStatus.RESTING;
    },
    startIdle() {
      this.status = EStatus.IDLE;
    },
    notify(msg) {
      new Notification(msg);
      this.$refs.aud.play();
    },
    save() {
      let data = JSON.stringify(this.persist);
      localStorage.setItem("data", data);
    },
    load() {
      let data = localStorage.getItem("data");
      if (data === null) {
        return;
      }
      data = JSON.parse(data);
      this.persist = data;
    }
  },
  mounted() {
    this.load();
    setInterval(() => {
      this.tick();
    }, 100);
  }
};
</script>

<style>
</style>