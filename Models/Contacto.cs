using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("Contactos")]
public class Contacto
{
    [Key]
    public int IdContacto { get; set; }
    public int IdUsuario { get; set; }
    [Required, MaxLength(20)]
    public string TipoContacto { get; set; } = string.Empty;
    [Required, MaxLength(150)]
    public string Valor { get; set; } = string.Empty;
    public bool EsPrincipal { get; set; } = false;
    public DateTime FechaCreacion { get; set; } = DateTime.Now;

    [ForeignKey("IdUsuario")]
    public Usuario? Usuario { get; set; }
}
