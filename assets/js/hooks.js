import flatpickr from "../vendor/flatpickr"
import { AsYouType } from "../vendor/libphonenumber-js.min"

// Calendar
const Calendar = {
  mounted() {
    this.pickr = flatpickr(this.el, {
      inline: true,
      mode: "range",
      showMonths: 2,
      onChange: (selectedDates) => {
        if (selectedDates.length !== 2) return
        this.pushEvent("dates-picked", selectedDates)
      },
    })

    this.handleEvent("add-unavailable-dates", (dates) => {
      this.pickr.set("disable", [dates, ...this.pickr.config.disable])
    })

    this.pushEvent("unavailable-dates", {}, (reply, ref) => {
      this.pickr.set("disable", reply.dates)
    })
  },

  destroyed() {
    this.pickr.destroy()
  },
}

// Phone Number Formatter
const PhoneNumber = {
  mounted() {
    this.el.addEventListener("input", (e) => {
      this.el.value = new AsYouType("US").input(this.el.value)
    })
  },
}

export default { Calendar, PhoneNumber }
