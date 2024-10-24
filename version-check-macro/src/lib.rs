use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, LitStr};
use semver::Version;

#[proc_macro_attribute]
pub fn version_gate(attr: TokenStream, item: TokenStream) -> TokenStream {
    let version_req = parse_macro_input!(attr as LitStr).value();
    let item = proc_macro2::TokenStream::from(item);
    
    let current_version = env!("CARGO_PKG_VERSION");
    let current = Version::parse(current_version).unwrap();
    let required = Version::parse(&version_req).unwrap();

    if current >= required {
        item.into()
    } else {
        quote!().into()
    }
}

#[proc_macro_attribute]
pub fn version_lt(attr: TokenStream, item: TokenStream) -> TokenStream {
    let version_req = parse_macro_input!(attr as LitStr).value();
    let item = proc_macro2::TokenStream::from(item);
    
    let current_version = env!("CARGO_PKG_VERSION");
    let current = Version::parse(current_version).unwrap();
    let required = Version::parse(&version_req).unwrap();

    if current < required {
        item.into()
    } else {
        quote!().into()
    }
}