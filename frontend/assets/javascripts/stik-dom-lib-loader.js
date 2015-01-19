// Stik-core - Version: 0.3.0 | From: 23-7-2014
(function( window, stik ){
  stik.boundary({
    as: "tplWrapper",
    from: "all",
    to: function( $template ){
      if ( window.hasOwnProperty( "MooTools" ) ) {
        return window.document.id( $template );
      } else if( window.hasOwnProperty( "Zepto" ) ) {
        return window.Zepto( $template );
      } else if ( window.hasOwnProperty( "jQuery" ) ) {
        return window.jQuery( $template );
      }
      throw "no DOM library found";
    }
  });
})( window, window.stik );

(function( stik ){
  stik.boundary({
    as: "tpl",
    from: "all",
    resolvable: true,
    to: function( $template, tplWrapper ){
      return tplWrapper( $template );
    }
  });
})( window.stik );
