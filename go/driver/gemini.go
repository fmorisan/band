package driver

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"

	"github.com/bandprotocol/band/go/dt"
	"github.com/ethereum/go-ethereum/common"
	"github.com/spf13/viper"
	"github.com/tidwall/gjson"
)

type Gemini struct{}

func (*Gemini) Configure(*viper.Viper) {}

func (*Gemini) QuerySpotPrice(symbol string) (float64, error) {
	pairs := strings.Split(strings.ToUpper(symbol), "-")
	if len(pairs) != 2 {
		return 0, fmt.Errorf("spotpx: symbol %s is not valid", symbol)
	}

	var url strings.Builder
	url.WriteString("https://api.gemini.com/v1/pubticker/")
	url.WriteString(pairs[0])
	url.WriteString(pairs[1])

	var client = &http.Client{}

	res, err := client.Get(url.String())
	if err != nil {
		return 0, err
	}
	defer res.Body.Close()

	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return 0, err
	}
	price := gjson.GetBytes(body, "last")

	if !price.Exists() {
		return 0, fmt.Errorf("QuerySpotPrice: key does not exist")
	}

	return price.Float(), nil
}

func (a *Gemini) Query(key []byte) dt.Answer {
	keys := strings.Split(string(key), "/")
	if len(keys) != 2 {
		return dt.NotFoundAnswer
	}
	if keys[0] == "SPOTPX" {
		value, err := a.QuerySpotPrice(keys[1])
		if err != nil {
			return dt.NotFoundAnswer
		}
		return dt.Answer{
			Option: dt.Answered,
			Value:  common.BigToHash(PriceToBigInt(value)),
		}
	}
	return dt.NotFoundAnswer
}
