/* Set the course seed. */
$.getJSON($SCRIPT_ROOT + '/_get_seed', function (data) {
    var gpio = getP8Gpio();
    var offset = 16;
    var bytes = data.result;
    console.log(bytes);
    for (var i = 0; i < 4; i++) {
        gpio[offset + i] = bytes[i];
    }
});

/* Track the best time. */
var best_time = -1;

const letterMap = [
    "A", "B", "C", "D", "E", "F", "G", "H",
    "I", "J", "K", "L", "M", "N", "O", "P",
    "Q", "R", "S", "T", "U", "V", "W", "X",
    "Y", "Z", "_"
];

(function () {
    var gpio = getP8Gpio();

    gpio.subscribe(function (newIndices) {

        // Get times
        $.getJSON($SCRIPT_ROOT + '/_get_times', function (data) {
            var time_list = $("#time");
            time_list.empty();
            var times = data.times;
            for (var i = 0; i < times.length; i++) {
                var ul_text = $("<li></li>").text(times[i][0] + ": " + times[i][3]);
                time_list.append(ul_text)
            }
        });

        /* handle the player name */
        const player_name = [];

        for (var i = 0; i < 5; i++) {
            player_name[i] = letterMap[gpio[i] - 1];
        }

        /* handle the time */
        const time = [];
        const num_time = [];

        for (var j = 0; j < 2; j++) {
            num_time[j] = gpio[j + 5];
            var zerofilled = ('00' + gpio[j + 5]).slice(-2);
            time[j] = zerofilled;
        }

        var pstatus = document.getElementById("pstatus");

        /* check if the course is completed */
        if (gpio[7] > 0) {

            var float_time = num_time[0] + num_time[1] * 0.01;

            // Set the latest time.
            console.log([player_name.join(''), float_time])
            $.get($SCRIPT_ROOT + '/_set_time', { name: player_name.join(''), time: float_time });

        }

        // Get best time
        $.getJSON($SCRIPT_ROOT + '/_get_user_best', function (data) {
            var best_p = $("#best");
            var best_time = data.result;
            console.log(best_time);
            best_p.text("YOUR BEST: " + best_time[0] + ": " + best_time[3]);
        });

        console.log(newIndices);
    });
})();