use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, LitStr};
use semver::{Version, VersionReq};

#[proc_macro_attribute]
pub fn version_gate(attr: TokenStream, item: TokenStream) -> TokenStream {
    let version_req = parse_macro_input!(attr as LitStr).value();
    let item = proc_macro2::TokenStream::from(item);
    
    // Get version from the calling crate instead
    let current_version = std::env::var("CARGO_PKG_VERSION")
        .expect("Could not find CARGO_PKG_VERSION in environment");
    
    let current = Version::parse(&current_version).unwrap();
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
    
    // Get version from the calling crate instead
    let current_version = std::env::var("CARGO_PKG_VERSION")
        .expect("Could not find CARGO_PKG_VERSION in environment");
    
    let current = Version::parse(&current_version).unwrap();
    let required = Version::parse(&version_req).unwrap();

    if current < required {
        item.into()
    } else {
        quote!().into()
    }
}

#[proc_macro_attribute]
pub fn version_range(attr: TokenStream, item: TokenStream) -> TokenStream {
    let version_req_str = parse_macro_input!(attr as LitStr).value();
    let item = proc_macro2::TokenStream::from(item);
    
    // Get version from the calling crate
    let current_version = std::env::var("CARGO_PKG_VERSION")
        .expect("Could not find CARGO_PKG_VERSION in environment");
    
    let current = Version::parse(&current_version)
        .expect("Failed to parse current version");
    
    // Parse the version requirement
    let version_req = VersionReq::parse(&version_req_str)
        .expect("Failed to parse version requirement");

    if version_req.matches(&current) {
        item.into()
    } else {
        quote!().into()
    }
}