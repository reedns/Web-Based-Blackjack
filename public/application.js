$(document).ready(function() {
  player_hits();
  player_stays();
  dealer_hits();
  blackjack_check();
});

function player_hits() {
  $(document).on("click", "form#hit", function() {
    $.ajax({
      type: "POST",
      url: "/game/player/hit"
    }).done(function(msg) {
      $("#game").replaceWith(msg)
    });

    return false;
  });
}

function player_stays() {
  $(document).on("click", "form#stay", function() {
    $.ajax({
      type: "POST",
      url: "/game/player/stay"
    }).done(function(msg) {
      $("#game").replaceWith(msg)
    });

    return false;
  });
}

function dealer_hits() {
  $(document).on("click", "form#dealer_hit", function() {
    $.ajax({
      type: "POST",
      url: "/game/dealer/hit"
    }).done(function(msg) {
      $("#game").replaceWith(msg)
    });

    return false;
  });
}

function blackjack_check() {
  $(document).on("click", "form#blackjack_check", function() {
    $.ajax({
      type: "POST",
      url: "/game/blackjack_check"
    }).done(function(msg) {
      $("#game").replaceWith(msg)
    });

    return false;
  });
}





